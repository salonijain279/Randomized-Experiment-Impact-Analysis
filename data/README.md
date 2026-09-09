# Data requirements

The original research datasets are not redistributed in this repository. The analysis accepts authorized local CSV files with the following schemas.

## Platform experiment

| Field | Meaning |
|---|---|
| `treated` | 1 for incentive treatment, 0 for control |
| `posted` | 1 if the user posted after assignment |
| `tenure` | User tenure at assignment |
| `premium_user` | Premium-status indicator |
| `num_post_before` | Number of posts before assignment |
| `first_timer` | First-time-contributor indicator |

## Education program

| Field | Meaning |
|---|---|
| `norm` | Normalized test score |
| `bal` | Program-treatment indicator |
| `pre` | Pre-program-period indicator |
| `post` | Post-program-period indicator |
| `test_type` | 0 for mathematics, 1 for language |

Do not commit student-level, user-level, licensed, or otherwise restricted source data.
