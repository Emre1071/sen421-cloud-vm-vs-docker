import http from "k6/http";
import { check } from "k6";
import { Rate } from "k6/metrics";

const http200 = new Rate("http_200");

export const options = {
  vus: 50,
  duration: "30s",
  thresholds: {
    http_200: ["rate>0.99"],
    http_req_duration: ["p(95)<500"],
  },
};

export default function () {
  const base = __ENV.BASE_URL || "http://127.0.0.1:8000";
  const path = __ITER % 2 === 0 ? "/compute" : "/payload";
  const res = http.get(`${base}${path}`);
  http200.add(res.status === 200);
  check(res, { "status is 200": (r) => r.status === 200 });
}

export function handleSummary(data) {
  const duration = data.metrics.http_req_duration.values;
  const reqs = data.metrics.http_reqs.values;
  const failed = data.metrics.http_req_failed.values.rate;
  const report = {
    mean_ms: duration.avg,
    median_ms: duration.med,
    p95_ms: duration["p(95)"],
    req_per_s: reqs.rate,
    failed_pct: failed * 100,
  };
  const text = JSON.stringify(report, null, 2) + "\n";
  const target = __ENV.RESULT_PATH;
  if (!target) {
    return { stdout: text };
  }
  return { [target]: text, stdout: text };
}
