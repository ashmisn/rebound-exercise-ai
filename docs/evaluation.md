# Computer-vision evaluation plan

The exercise tracker should be evaluated on recorded sessions before making accuracy claims. The current backend has no labeled evaluation dataset, so this document defines the benchmark and leaves results to be filled in after data collection.

## Dataset protocol

Record representative clips for every configured movement with:

- at least 20 clips per exercise across different users, camera distances, lighting conditions, and left/right orientations
- a human-labeled rep count and full/partial/invalid movement label for every clip
- timestamps for each ground-truth rep start and completion
- failure-condition labels: no pose, low visibility, side occlusion, camera movement, and out-of-frame motion

Keep a user-level train/development/test split if the dataset is later used to tune thresholds. Do not put identifiable patient video in this repository.

## Metrics

| Area | Metric | Definition |
| --- | --- | --- |
| Rep counting | Absolute error | `abs(predicted_reps - labeled_reps)` per clip |
| Rep counting | Count accuracy | Clips with exact predicted count / total clips |
| Rep counting | False-rep rate | Predicted reps with no matching labeled rep / predicted reps |
| Rep counting | Missed-rep rate | Labeled reps with no matching prediction / labeled reps |
| Movement state | Precision, recall, F1 | Full/partial/invalid labels against labeled transitions |
| Form feedback | Feedback correctness | Appropriate correction/encouragement label against the labeled movement state |
| Timing | Boundary error | Median seconds between predicted and labeled rep completion |
| Runtime | P50/P95 latency | Time from `/api/analyze_frame` request to response |
| Robustness | Failure recovery rate | Valid feedback responses after injected/recorded failure conditions |

## Results template

| Exercise | Clips | Exact count accuracy | Mean absolute error | P95 latency |
| --- | ---: | ---: | ---: | ---: |
| Shoulder flexion | — | — | — | — |
| Shoulder abduction | — | — | — | — |
| Elbow flexion | — | — | — | — |
| Knee flexion | — | — | — | — |
| Wrist flexion | — | — | — | — |

Until this table is populated, describe the CV system as a prototype and avoid presenting the session accuracy score as validated clinical accuracy.
