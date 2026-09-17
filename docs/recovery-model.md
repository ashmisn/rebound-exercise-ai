# Recovery model

REBOUND exposes a serialized Cox proportional hazards model through `POST /api/predict_recovery`.

## Artifact contract

| Artifact | Role |
| --- | --- |
| `backend/model/cph_model.joblib` | Serialized model loaded with `joblib` |
| `backend/model/model_features.json` | Checked-in feature-order metadata; the current backend keeps a matching `MODEL_FEATURES` list in `main.py` rather than loading this JSON at runtime |
| `backend/main.py` | Request schema, feature-vector construction, and endpoint |

The current request accepts:

```json
{
  "Age": 30,
  "Health_Score": 7.5,
  "Physio_adherence": 0.8,
  "Complication_count": 0,
  "Inflammation_marker": 1.5,
  "Previous_injury": 0,
  "Injury_Type": "Shoulder injury"
}
```

The endpoint creates a zero-filled feature frame in the `MODEL_FEATURES` order, writes the scalar patient features, sets `Injury_<Injury_Type>` to `1`, and calls the loaded model's `predict_median` method. The response is the integer `median_recovery_days` estimate.

## Important limitations

- The model training code, dataset provenance, validation metrics, confidence intervals, and calibration report are not in this repository.
- Feature names are case-sensitive. An injury value that does not map to a stored `Injury_*` column leaves the injury vector at zero and logs a warning.
- Predictions are estimates for product exploration, not clinical decisions.
- Predictions are not persisted or joined to a user's progress history yet.
