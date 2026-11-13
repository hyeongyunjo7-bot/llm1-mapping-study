# LLM1 공식 문서 매핑 실험 공유본

Aqara LED Bulb T2 E26의 Zigbee → oneM2M 매핑 초안을 공식 문서에서 추출한 실험입니다. 바인딩 프로파일 항목과 승인 명세 스키마 검토를 위한 자료입니다.

## 먼저 볼 자료

| 목적 | 파일 |
| --- | --- |
| 조건·추론별 필드 반복성 | [field-summary.csv](data/field-summary.csv) |
| 노션에 제시한 실제 출력 10개 | [examples.json](data/examples.json) |
| A조건 대표 실행 원문 | [03-A-low-r4 원문](representative-A/response.json) |
| 대표 실행 선정 근거·한계 | [selection.md](representative-A/selection.md) |
| 전체 실험 설명 | [experiment-report.md](docs/experiment-report.md) |
| 밝기 역변환 정정 | [brightness-policy.md](docs/brightness-policy.md) |
| 83개 종료 기록 및 응답 위치 | [run-inventory.json](data/run-inventory.json) |

## 범위와 결과

- 요청 모델: gpt-6.1-sol. 추론 수준: low / medium / high.
- 완성 응답 81건: 유효 78건 + 입력 결함으로 제외한 3건. 별도로 응답 없는 timeout 2건을 기록합니다.
- 유효 78건 = 고정 48문항 6회 + 자유 추출 72회.
- 공통 필드 본분석: A30 + B9 + C9 + D9 + F9 = 66회 × 61필드 = 4,026판정.
- 자유 추출 탐색 6회는 61필드 본분석 밖입니다. A30은 추론별 10회, 조건 간 균형 비교는 A의 기존 9회를 사용했습니다.
- 실제 IPE 실행, CSE 연동, 실제 전구·endpoint·지원 클러스터 검증은 이 실험의 범위가 아닙니다.

## 원본과 가공본

`runs/**/response.json` 81개와 `representative-A/response.json`은 원본 바이트를 보존했습니다. 오류가 있는 응답도 수정하지 않았습니다. `field-summary.csv`, `field-summary.json`, `examples.json`은 기존 발표용 파일과 동일합니다.

`metadata.json`은 모델·시간·usage·입력 해시 등 필요한 항목만 내보낸 가공본입니다. `run-inventory.json`은 공유본의 상대 경로로 연결합니다. `examples.json`의 원래 절대 경로는 출처 보존을 위해 그대로 남아 있으므로 실제 파일은 실행 이름과 `data/run-inventory.json`을 이용해 찾으십시오.

## 주의할 해석

정확히 채움은 supported + proposed_consistent입니다. 문서 사실과 타당한 구현 정책 제안은 같은 뜻이 아닙니다. 반복 빈도가 높다는 이유만으로 승인 명세로 확정하지 마십시오. 근거 부족에 따른 적절한 유보는 누락·오류와 구분합니다.

대표 실행은 기존 61필드 평가에서 61/61인 **12개 동률 중 하나**입니다. 유일한 최우수, 전체 문장 무오류, 승인 완료 또는 제품 호환 보장이 아닙니다.

## 검증

저장소 루트에서 PowerShell 7로 `pwsh -File scripts/verify.ps1`을 실행하면 파일 해시, JSON 구문, 응답 수, 대표 원문 동일성을 확인합니다. Python 3에서는 `python scripts/verify.py`로 같은 무결성을 확인할 수 있습니다. 모델을 호출하거나 실험을 재실행하지 않습니다.

입력 원문·비공개 판정 원장·평가 정답·방법론 DOCX·인증정보는 포함하지 않았습니다. 따라서 이 공유본만으로 기존 평가를 전부 재실행할 수는 없습니다. 공식 자료의 판본과 입력 조건은 [sources.md](docs/sources.md)에 설명했습니다.

이 저장소의 범위는 LLM1 매핑 실험입니다. TinyIoT FCNTA, 이전 Modbus IPE, 해커톤 대시보드 전체를 포함하지 않습니다. 원본 표준과 제3자 인용의 권리는 원저작자에게 있으며, 별도 재배포 라이선스를 부여하지 않습니다.