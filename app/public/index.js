"use strict";

document.addEventListener("DOMContentLoaded", function() {
  const edgeUrlMeta = document.querySelector('meta[name=wifidiag-edge]');
  let edgeUrl;
  if (edgeUrlMeta) {
    edgeUrl = edgeUrlMeta.content;
  } else {
    edgeUrl = `${document.location.origin}/`;
  }
  const now = (new Date()).getTime();
  const testDataTiny = `${edgeUrl}tiny.svg?t=${now}&c=`;
  const testData = `${edgeUrl}data.svg?t=${now}`;

  const latencyMeasureInterval = 250;
  const latencyMeasureTimeout = 1200;
  const latencyMeasureDuration = 5000;

  let q = null;
  if (document.location.search != "") {
    q = document.location.search.slice(1, q.length);
  }
  let advancedData = {
    "client": {
      "q": q,
      "ua": navigator.userAgent,
    },
    "bandwidth": {},
    "latency": {},
  };
  const updateDataDisplay = function() { document.querySelector('#advanced_data_pre').innerHTML = JSON.stringify(advancedData, null, '  ') };

  if (!window.performance) {
    updateDataDisplay();
    return;
  }

  const reportForm = document.querySelector('#report_form');

  reportForm.onsubmit = function (e) {
    e.preventDefault();
    let payload = JSON.stringify({
      data: advancedData,
    });

    reportForm.querySelector('button').disabled = true;
    fetch("/api/report", {credentials: 'include', method: 'POST', body: payload}).then((resp) => {
      if (!resp.ok) {
        reportForm.querySelector('button').disabled = false;
        reportForm.querySelector('p').innerHTML = `resp error: ${resp.status}`;
      } else {
        reportForm.querySelector('p').innerHTML = 'Reported!';
      }
    }).catch((error) => {
      reportForm.querySelector('button').disabled = false;
      reportForm.querySelector('p').innerHTML = `error: ${error}`;
    });
  };

  const completeMeasure = function () {
    document.querySelector('#measuring').className = 'hide';
    reportForm.className = '';
  }

  let latencyImages = [];
  const completeLatencyMeasure = function () {
    let attempts = advancedData.latency.attempts;
    let start = advancedData.latency.start;
    let succeededAttempts = attempts.filter((v) => v !== null);
    let success = succeededAttempts.length;
    let fail = attempts.filter((v) => v === null).length;
    let avg = succeededAttempts.reduce((v, r) => r + v) / succeededAttempts.length;
    advancedData.latency = {
      "time": ((new Date()).getTime() - start),
      "ok": success,
      "fail": fail,
      "rate": 100.0*(success/attempts.length),
      "min": succeededAttempts.reduce((v, r) => r < v ? r : v),
      "avg": avg,
      "max": succeededAttempts.reduce((v, r) => r > v ? r : v),
      "mdev":succeededAttempts.reduce((v, r) => r + Math.abs(avg - v)) / succeededAttempts.length,
    };
    updateDataDisplay();
  };
  const measureLatency = function () {
    advancedData.latency.attempts = [];
    advancedData.latency.start = (new Date()).getTime();
    measureLatencyIterate(1);
  };
  const measureLatencyIterate = function (count) {
    let measure = {};
    measure.image = new Image();
    measure.image.onload = () => measureLatencyIterateCallback(count, measure, false);
    measure.image.src = `${testDataTiny}${count}`
    measure.timeout = setTimeout(() => measureLatencyIterateCallback(count, measure, true), latencyMeasureTimeout);
  };
  const measureLatencyIterateCallback = function (count, measure, timeout) {
    if (measure.done) return;
    measure.done = true;

    if (timeout) {
      measure.image.src = null;
      advancedData.latency.attempts.push(null);
    } else {
      clearTimeout(measure.timeout);
      let perfData = window.performance.getEntriesByName(measure.image.src)[0];
      let latency = perfData.responseStart - perfData.connectStart;
      advancedData.latency.attempts.push(latency);
    }

    measure.timeout = null;
    updateDataDisplay();
    if (((new Date()).getTime() - advancedData.latency.start) < latencyMeasureDuration) {
      setTimeout(() => {
        measureLatencyIterate(count + 1);
      }, latencyMeasureInterval);
    } else {
      completeLatencyMeasure();
      completeMeasure();
    }
  };

  let bandwidthImage;
  const bandwidthCallback = function (e) {
    let perfData = window.performance.getEntriesByName(testData)[0];
    let speed = perfData.transferSize / (perfData.responseEnd - perfData.responseStart);
    let mbps = (speed * 8) / 1024 / 1024 * 1000;
    console.log(perfData);
    advancedData.bandwidth.mbps = mbps;
    updateDataDisplay();
    measureLatency();
  }
  const measureBandwidth = function () {
    bandwidthImage = new Image;
    bandwidthImage.onload = bandwidthCallback;
    bandwidthImage.src = testData;
  }

  measureBandwidth()
});
