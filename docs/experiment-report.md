# 기존 발표자료 공유 사본

노션 원문: https://app.notion.com/p/4137e7d89d38811a8301e605ad733032

본문은 기존 발표자료이며, 공유용 링크와 제외 자료 안내만 조정했습니다. 인터랙티브 그림은 원문에서 확인하십시오.

<b>유효 응답 78회 · 자유 추출 72회 · 공통 필드 본분석 66회 / 4,026판정.</b> 분모가 다른 결과를 하나의 정확도로 합치지 않았습니다.

## 01 · 무엇을 평가하는 실험인가

<b>연구 질문: 공식 문서만 받은 LLM1은 어떤 매핑 필드를 정확하고 반복 가능하게 채우는가?</b>

대상은 Aqara LED Bulb T2 E26의 Zigbee → oneM2M 매핑 초안입니다. LLM1은 문서를 읽고 관리할 기능·속성을 찾아, 기기 쪽 정보와 oneM2M 쪽 표현을 연결합니다. 예를 들어 ‘전구의 켜짐 상태를 어느 Zigbee 속성에서 읽고, 어느 oneM2M 속성으로 표현할지’를 정리하는 역할입니다.

여기서 <b>source</b>는 Zigbee 쪽 cluster·attribute·명령·타입이고, <b>target</b>은 oneM2M 쪽 ModuleClass·DataPoint·타입입니다. <b>매핑 필드</b>는 이 초안을 구성하는 개별 값입니다.

먼저 다음 절에서 <b>입력 조건</b>과 <b>추론 수준</b>을 정의합니다. 이후 공식 문서의 세부 범위 → 실행 횟수 → 평가 방법 → 결과 → 실제 출력 순서로 설명합니다. 이 실험은 문서 추출·매핑 초안을 평가하며, 코드 생성이나 실제 기기·CSE 연동을 검증한 실험은 아닙니다.

---

## 02 · 먼저 정의: 입력 조건 A–F와 추론 수준

<b>조건 A–F는 LLM1에 제공한 문서 조합의 이름입니다.</b> 모델 종류나 추론 수준을 뜻하지 않습니다. 기준 입력에서 특정 문서를 빼거나 더해, 어떤 매핑 정보가 달라지는지 비교했습니다.

### 기준 입력을 이루는 네 가지 문서

| 문서 | 쉬운 설명 | 매핑에서 필요한 이유 |
| --- | --- | --- |
| Aqara T2 공식 사용설명서 | 어떤 제품이고 어떤 기능·변형 모델이 있는가 | 관리 대상과 기기 범위를 정하기 위해 |
| ZCL · Zigbee Cluster Library | Zigbee의 기능·속성·명령을 정의한 표준 | source cluster/attribute ID, 타입, 값 범위, 명령을 찾기 위해 |
| oneM2M TS-0023 | 표준 데이터 모델과 리소스 표현을 정의한 문서 | target ModuleClass·DataPoint·타입·단위와 리소스 매핑을 찾기 위해 |
| oneM2M TS-0033 | 외부 기기 기능을 oneM2M으로 노출·연동하는 방법을 다룬 문서 | 기능 동기화·리소스 구성·생명주기 설명을 찾기 위해 |

### 각 조건의 정의와 비교 목적

<b>A = 사용설명서 + ZCL + TS-0023 + TS-0033</b>을 모두 제공한 기준 조건입니다. B·C·D·F는 모두 이 A에서 출발합니다. 사용설명서는 모든 실행 조건에 유지했습니다.

| 조건 이름 | 제공한 입력 또는 A 대비 변화 | 확인하려는 차이 |
| --- | --- | --- |
| <b>A · 기준 문서 모두 제공</b> | 사용설명서 + ZCL + TS-0023 + TS-0033 | 필요한 표준 문서를 함께 주면 어떤 필드가 반복적으로 채워지는가 |
| <b>B · ZCL 제외</b> | A에서 Zigbee 기능·속성·명령 정의를 제거 | source 식별자·타입·범위를 근거 없이 채우는가, 유보하는가 |
| <b>C · TS-0023 제외</b> | A에서 표준 데이터 모델 및 SDT 리소스 매핑 근거를 제거 | 표준 target을 선택하는가, custom 후보를 제안하는가, 유보하는가 |
| <b>D · TS-0033 제외</b> | A에서 IPE 기능 노출·연동·생명주기 근거를 제거 | 개별 기능 매핑과 연동·리소스 구성 설명 중 무엇이 달라지는가 |
| <b>E · 공식 기기 명세 추가 — 보류</b> | A에 T2가 실제 구현한 endpoint·cluster·attribute 명세를 추가할 계획 | 일반 표준 후보가 실제 기기에 연결할 수 있는 매핑으로 바뀌는가 |
| <b>F · ZCL 3개 기능 절 추가</b> | A에 ZCL §3.7 Scenes·§3.9 On/Off Switch Configuration·§3.11 Alarms를 추가 | 입력 범위가 넓어지면 발견 기능·누락·오류가 어떻게 달라지는가 |

<b>E는 공식 기기 명세가 확보될 때까지 사용자 결정으로 보류했으며, 실행 결과가 없습니다.</b> 따라서 결과 비교에는 A·B·C·D·F만 등장합니다. E와 F는 독립적으로 추가할 계획인 조건이었고, E를 건너뛴 것은 실행 누락이 아닙니다.

### F조건에서 실제로 추가한 절

**F는 A의 문서를 그대로 유지하면서 같은 ZCL R8의 아래 3개 절을 더 제공한 조건입니다.** ZCL 전체 문서를 넣거나, 같은 정보를 길게 풀어 쓴 조건이 아닙니다.

| 추가한 절 | 어떤 기능을 정의하는가 | 기기 지원과의 구분 |
| --- | --- | --- |
| **§3.7 Scenes** | 여러 상태를 장면으로 저장하고 호출하는 기능 | 표준에 정의돼 있다는 사실만으로 T2의 지원을 확정할 수 없음 |
| **§3.9 On/Off Switch Configuration** | 스위치의 유형·동작을 설정하는 기능 | 전구가 이 기능을 구현했다는 명세를 추가한 것이 아님 |
| **§3.11 Alarms** | 경보 관련 기능 | 기기의 실제 구현 여부는 별도 확인이 필요함 |

A에 있던 **§3.8 On/Off, §3.10 Level Control, §3.19 Level Control for Lighting, §5.2 Color Control**은 F에서도 모두 유지했습니다. Aqara 사용설명서와 TS-0023·TS-0033도 동일하게 유지했습니다.

추가 본문은 **79,254자**이며 전체 입력 문서 본문은 **309,123자 → 388,377자(+25.6%)**입니다. ‘새 기능 절을 읽고 관리 후보를 어떻게 선택하는지’와 ‘기존 핵심 필드의 누락이 달라지는지’를 함께 관찰했습니다. 그래프에서 짧게 쓴 **F · 3개 절 추가**도 이 조건을 뜻합니다.

### 추론 수준은 입력 조건과 별개의 축

모든 실행의 요청 모델은 <code>gpt-6.1-sol</code>입니다. 같은 문서 조건에서 모델의 추론 설정만 \*\*low(낮음)·medium(중간)·high(높음)\*\*로 바꿨습니다.

예를 들어 <b>C-high</b>는 ‘TS-0023을 제외한 문서 조합을 주고, 추론 수준을 high로 설정한 실행’을 뜻합니다. 뒤의 결과는 먼저 A의 추론 수준별 반복성을 비교하고, 다음으로 A/B/C/D/F의 입력 차이를 비교합니다.

---

## 03 · 실제 제공한 공식 문서

| 문서·판본 | 입력한 절과 역할 | 해석의 경계 |
| --- | --- | --- |
| Aqara LED Bulb T2 E26 한국어 사용설명서 · 판본 미표기 | LB-L01E(CCT), LB-L01D(RGB CCT), 프로토콜 명칭·정격·설정/초기화 절차 | endpoint, 구현 cluster/attribute 목록, 제품별 색온도 한계는 없음 |
| Zigbee Cluster Library R8 · 문서 075123 | §3.8 On/Off, §3.10 Level Control, §3.19 Level Control for Lighting, §5.2 Color Control의 명령 절 포함 | 일반 표준 정의이며 T2가 실제 지원한다는 증거는 아님 |
| oneM2M TS-0023 v5.7.0 | §5.3 ModuleClasses 및 DataPoint, §6.2 SDT→oneM2M 리소스 매핑 | 대상 모델명·타입·접근권한·단위 및 FCNT 표현의 근거 |
| oneM2M TS-0033 · 2026-11-02 저장본 | §6.2 IPE 기능 노출·동기화, §7.3 리소스 선택·생명주기 | latest URL에서 저장한 본문; 정확한 release 번호는 확인되지 않음 |
| F조건 추가 ZCL R8 | §3.7 Scenes, §3.9 On/Off Switch Configuration, §3.11 Alarms | A에 기능 절 3개를 추가한 조건; ZCL 전체 문서 입력은 아님 |

문서 링크: [Aqara 공식 사용설명서 배포본](https://cdn.shopify.com/s/files/1/0710/9220/7830/files/LED_Bulb_T2_User_Manual_KR.pdf?v=1765763767) · [TS-0023 §5.3](https://specifications.onem2m.org/ts/ts-0023/v5.7.0/5.3/) · [TS-0023 §6.2](https://specifications.onem2m.org/ts/ts-0023/v5.7.0/6.2/) · [TS-0033 §6.2](https://specifications.onem2m.org/ts/ts-0033/latest/6.2/) · [TS-0033 §7.3](https://specifications.onem2m.org/ts/ts-0033/latest/7.3/).

ZCL은 보관 PDF의 판본·해시와 실제 입력 발췌문으로 추적합니다. 입력 기록에서 원래 다운로드 URL을 확정할 수 없어 임의 링크를 추가하지 않았습니다. 웹페이지의 현재 내용 대신 당시 입력 패킷을 재현 기준으로 삼습니다.

A조건 텍스트 구성: 사용설명서 3,956자 + ZCL 183,624자 + TS-0023 109,964자 + TS-0033 11,579자 = <b>309,123자</b>. JSON 문법과 과제 지시문을 제외한 문서 본문 문자 수입니다.

### LLM1에 제공한 과제와 출력 형식

<b>문서 입력 → 관리 기능·속성 자유 발견 → 출처가 연결된 매핑 초안 → 연구자 측 필드 평가</b>

자유 추출 프롬프트에는 기능 목록·문항 수·예시 정답을 주지 않았습니다. 모델이 <code>device_variants</code>, <code>inventory</code>, <code>excluded_candidates</code>, <code>open_questions</code>를 직접 작성하게 했습니다. 각 항목에는 source interface, target, direction, conversion, evidence, uncertainties를 요구했습니다.

출력은 ① 기기 설명서의 사실 ② 일반 Zigbee/oneM2M 표준 정의 ③ 구현 정책 제안 ④ 미확인 정보를 구분하도록 했습니다. 표준 SDT 대상이 정당화되지 않으면 custom 후보 또는 이유 있는 유보를 허용했습니다.

각 실행은 별도 세션이며, 입력으로 고정한 공식 문서 텍스트만 사용했습니다. 검색·도구·기존 출력·비공개 평가표·방법론 DOCX를 피험 모델에 제공하지 않았습니다. 초기 48문항 실험은 별도 과제이므로 자유 추출 결과와 합산해 정확도를 계산하지 않습니다.

---

## 04 · 전체 실험 이력과 중복 제거

조건 이름: A=기준 문서 모두 제공 · B=ZCL 제외 · C=TS-0023 제외 · D=TS-0033 제외 · F=ZCL 3개 기능 절 추가. E=공식 기기 명세 추가는 보류했습니다.

> 원래 노션의 인터랙티브 그림은 원문 페이지에서 확인하실 수 있습니다.

서로 다른 실행 기준: 78회 → 자유 추출 72회 → 공통 필드 평가 66회. 아래 막대는 66회의 조건 구성입니다.

| 단계 | 새 유효 응답 | 설계·결과 | 본분석 처리 |
| --- | --- | --- | --- |
| 초기 고정 48문항 | 6회 | 추론별 2회, 288/288 기준 정답 일치 | 자유 추출과 별도 |
| 자유 추출 탐색 | 6회 | 추론별 2회; 핵심 조명 4개 기능군은 모두 발견 | 기능군/행 단위 평가; 61필드 본분석 밖 |
| A/B 문서 제거 | 18회 | A9 + B9, 각각 추론별 3회 | 61필드로 후향 재평가 |
| A 반복 확장 | 21회 | 추론별 7회 추가 → 기존 A9와 합쳐 A30 | A는 추론별 총 10회 |
| C/D/F 입력 조건 확장 | 27회 | 각 조건 9회, 각각 추론별 3회 | 기존 A9를 대조군으로 재사용 |
| 합계 | 78회 | 고정 문항 6 + 자유 추출 72 | 공통 평가: 자유 추출 66회 × 61필드 = 4,026판정 |

<b>A30 + B9 + C9 + D9 + F9 = 66회</b>가 공통 필드 본분석입니다. 자유 추출 탐색 6회도 같은 A 입력을 사용했지만, 기존의 평가 수준이 달라 별도 탐색 결과로 남겼습니다. 따라서 같은 A 입력의 전체 출력은 36회이고, 아래 A 필드 표의 분모는 재평가된 30회입니다.

종료 기록은 83건: 완성 응답 81건 중 입력 결함 3건 제외 → 유효 78건, 응답 없이 끝난 timeout 2건입니다. 이와 별개로 초기 실행 환경 기동 실패 3건이 기록돼 있습니다. timeout 2건은 같은 입력·설정으로 재시도하여 N28/N29에서 성공했습니다. 복사된 A 대조군은 새 실행으로 세지 않았습니다.

제외한 최초 3건은 PDF 페이지 구분 문자를 줄바꿈으로 처리하면서 발췌 위치가 어긋난 입력 결함 때문입니다. 입력을 고친 후의 6회만 고정 문항 결과에 포함했습니다. Modbus는 준비 단계이며 실행 결과가 없습니다.

### 조건별 입력량과 반복 수

| 조건 | A 대비 변경 | 문서 본문 문자 수 | 필드 분석 실행 수 |
| --- | --- | --- | --- |
| A · 기준 | 설명서 + ZCL + TS-0023 + TS-0033 | 309,123 | 30회: low/medium/high 각10 |
| B · ZCL 제외 | 소스 프로토콜 정의 제거 | 125,499 | 9회: 각3 |
| C · TS-0023 제외 | ModuleClass·DataPoint 및 SDT 리소스 매핑 근거 제거 | 199,159 | 9회: 각3 |
| D · TS-0033 제외 | IPE 연동·기능 노출·리소스 생명주기 근거 제거 | 297,544 | 9회: 각3 |
| F · ZCL 3개 기능 절 추가 | ZCL §3.7 Scenes·§3.9 On/Off Switch Configuration·§3.11 Alarms, 79,254자 추가 | 388,377 (+25.6%) | 9회: 각3 |
| E · 공식 기기 인터페이스 명세 추가 | 공식 cluster·attribute 명세 확보 대기 | 입력 미구성 | 사용자 결정으로 보류 · 0회 |

조건 비교 표는 <b>A의 기존 9회와 B/C/D/F 각 9회</b>를 사용하여 각 추론 수준의 반복 수를 3회로 맞췄습니다. A30은 추론별 반복성 분석에 사용합니다. A 대조군은 과거 실행이므로 모든 조건을 같은 시점에 무작위 배치한 실험은 아닙니다.

---

## 05 · 평가 방법: 정확성·누락·유보·반복성

평가 단위는 <b>실행 1회 안의 특정 매핑 필드 1개</b>입니다. On/Off·밝기·색온도·RGB의 61개 핵심 필드를 평가했습니다. LLM이 생성한 행 개수나 문장 수를 정확도 분모로 쓰지 않았습니다.

| 판정 | 의미 | 본분석 4,026건 |
| --- | --- | --- |
| supported | 제공 문서에 근거한 값·의미가 맞음 | 3,242 |
| proposed\_consistent | 제안임을 표시하고 의미·수학이 일관됨 | 203 |
| missing\_available | 입력에 근거가 있지만 해당 필드가 빠짐 | 58 |
| incorrect | 명시한 값·변환이 틀림 | 1 |
| appropriate\_abstention | 입력에 근거가 없어 적절히 비워 둠 | 486 |
| correct\_deferral | 직접 대상 선택 등을 이유와 함께 유보 | 36 |

이후 표의 <b>정확히 채움 = supported + proposed\_consistent</b>입니다. 문서 사실과 설계 제안은 평가 원장에 구분돼 있습니다. 근거 없는 필드는 0% 정확도로 표시하지 않습니다. 올바른 유보도 채움 성공과 따로 셉니다.

반복성은 같은 조건·추론 수준에서 해당 필드가 정확히 채워진 빈도입니다. 의미상 같은 값을 인정하므로 JSON 키 이름의 문자 단위 동일성과는 다릅니다. custom 모델의 이름·타입·단위 일관성은 별도 사례로 제시합니다.

61필드 기준은 기존 18회 결과를 본 뒤 정하고, 추가 호출 전 고정했습니다. 기존 18회는 후향 평가이고, 독립 전문가의 블라인드 정답 검증은 아직 없습니다. 4,026개 판정은 4,026개의 독립 실험이 아닙니다.

---

## 06 · 조건을 알고 읽는 핵심 결과

<b>공식 문서만 받은 LLM1은 어떤 매핑 필드를 정확하고 반복 가능하게 채우는가?</b>

대상은 Aqara LED Bulb T2 E26의 Zigbee → oneM2M 매핑 초안입니다. 요청 모델은 <code>gpt-6.1-sol</code>, 추론 수준은 low·medium·high입니다.

<b>A조건 30회에서 기본 식별자와 On/Off·밝기 표준 대상 선택은 안정적이었지만, 수치 범위·예외 처리·변환식은 별도 검증이 필요했습니다.</b> 밝기 상한 명시 21/30회, 색온도 유효 범위 명시 19/30회, 밝기 정규화 정책의 수학적 일관성 29/30회였습니다.

이 자료는 문서 추출·매핑 초안의 실험 결과입니다. 기기 endpoint/실제 구현 여부, IPE 코드, 실제 Zigbee 통신 및 CSE 연동은 검증 대상에 포함되지 않았습니다.

이제 A(기준 문서 모두 제공)의 추론 수준별 결과를 먼저 보고, 이후 입력 문서 조합을 바꾼 조건들을 비교합니다.

---

## 07 · A · 기준 문서 모두 제공: 추론 수준별 비교

이 절의 A는 사용설명서·ZCL·TS-0023·TS-0033을 모두 준 조건입니다. 입력은 같고 low·medium·high 설정을 비교합니다.

> 원래 노션의 인터랙티브 그림은 원문 페이지에서 확인하실 수 있습니다.

A조건 추론별 10회 비교. 색온도 범위는 high에서도 7/10이며, 수학적으로 잘못된 밝기 역변환은 low에서 1회 나왔습니다.

| 필드 | low | medium | high | 합계 |
| --- | --- | --- | --- | --- |
| On/Off cluster | 10/10 | 10/10 | 10/10 | 30/30 |
| On/Off attribute | 10/10 | 10/10 | 10/10 | 30/30 |
| On/Off 표준 대상 ModuleClass | 10/10 | 10/10 | 10/10 | 30/30 |
| 밝기 표준 대상 ModuleClass | 10/10 | 10/10 | 10/10 | 30/30 |
| 밝기 target 상한 100 | 6/10 | 6/10 | 9/10 | 21/30 |
| 밝기 source 0 사용 금지 명시 | 8/10 | 9/10 | 10/10 | 27/30 |
| 밝기 정규화 정책의 수학적 일관성 | 9/10 | 10/10 | 10/10 | 29/30 |
| 색온도 source 유효 하한 | 5/10 | 7/10 | 7/10 | 19/30 |
| 색온도 source 유효 상한 | 5/10 | 7/10 | 7/10 | 19/30 |
| 색온도 K↔mired 관계 | 10/10 | 10/10 | 10/10 | 30/30 |
| 색온도 예외·유효값 검증 | 8/10 | 8/10 | 10/10 | 26/30 |
| RGB 표준 대상 선택 | 9/10 | 10/10 | 9/10 | 28/30 |

소스 cluster·attribute·type·access의 기본 12필드(On/Off·밝기·색온도 각각 4개)는 모두 30/30회였습니다. On/Off <code>binarySwitch.state</code>와 밝기 <code>brightness.brightness</code>도 각각 30/30회였습니다.

밝기 상한은 low/medium 6/10에서 high 9/10으로, 색온도 예외 검증은 8/10에서 high 10/10으로 높았습니다. 그러나 색온도 유효 범위는 high도 7/10에 그쳤고, RGB 대상은 medium 10/10·high 9/10이었습니다. <b>high가 모든 필드를 항상 더 잘 채운다고 결론 내릴 수 없습니다.</b>

RGB 대상 미선택 2회는 오류가 아니라 근거를 제시한 유보입니다. 밝기 정규화 low의 1회 실패는 실제 역변환식 오류이며, 아래 원문으로 확인합니다. 10/10은 관측된 10회에서의 결과이지 미래 성공률 100% 보장이 아닙니다.

---

## 08 · 입력 조건 비교: 어떤 문서를 빼거나 더했는가

A=기준 문서 모두 제공 · B=ZCL 제외 · C=TS-0023 제외 · D=TS-0033 제외 · F=ZCL 3개 기능 절 추가. 아래 비교는 각 조건 9회로 반복 수를 맞췄습니다.

> 원래 노션의 인터랙티브 그림은 원문 페이지에서 확인하실 수 있습니다.

ZCL을 빼면 source 필드, TS-0023을 빼면 표준 target 필드의 근거가 사라집니다. 반복 수를 맞춘 A/B/C/D/F 비교입니다.

| 필드 | A 기준 | B ZCL 제외 | C TS-0023 제외 | D TS-0033 제외 | F 3개 절 추가 |
| --- | --- | --- | --- | --- | --- |
| On/Off source cluster | 9/9 | 근거 없음·유보 9/9 | 9/9 | 9/9 | 9/9 |
| On/Off standard ModuleClass | 9/9 | 9/9 | 근거 없음·유보 9/9 | 9/9 | 9/9 |
| 밝기 standard ModuleClass | 9/9 | 9/9 | 근거 없음·유보 9/9 | 9/9 | 9/9 |
| 밝기 target 상한 100 | 6/9 | 9/9 | 근거 없음·유보 9/9 | 5/9 | 6/9 |
| 색온도 source 하한 | 5/9 | 근거 없음·유보 9/9 | 6/9 | 8/9 | 8/9 |
| 색온도 source 상한 | 5/9 | 근거 없음·유보 9/9 | 6/9 | 8/9 | 8/9 |
| 색온도 K↔mired 관계 | 9/9 | 근거 없음·유보 9/9 | 9/9 | 9/9 | 9/9 |
| 색온도 예외·유효값 검증 | 7/9 | 근거 없음·유보 9/9 | 9/9 | 9/9 | 8/9 |

### 결과를 읽기 전에: 유보·누락·제안은 다릅니다

**source는 Zigbee에서 읽거나 제어할 정보, target은 oneM2M에서 그 정보를 표현할 모델·항목입니다.** ZCL은 source 정의, TS-0023은 표준 target 정의, TS-0033은 기능 노출·연동 설명의 주된 근거입니다. 일부 리소스 표현에는 문서 간 근거가 겹칩니다.

- **적절한 유보:** 제공 문서에 근거가 없어 표준 사실로 확정하지 않음. 반드시 모든 JSON 값이 null이라는 뜻은 아님.
- **누락:** 제공 문서에 근거가 있는데도 필요한 정보를 출력에 적지 않음.
- **custom 제안:** 표준에서 추출한 사실과 구분하여 자체 이름·구조·정책을 제안함.

아래 수치는 **각 조건 9회(low·medium·high 각 3회)**를 비교한 결과입니다. A는 반복 확장 30회 전체가 아니라 기존 9회만 대조군으로 사용했습니다. LLM에는 필드별 질문을 주지 않았고, 자유롭게 만든 초안을 평가자가 공통 필드로 확인했습니다.

### B · ZCL 제외: Zigbee 연결 정보는 비우고 oneM2M 표준 대상은 선택

**남은 입력: 사용설명서 + TS-0023 + TS-0033.** ZCL이 없으므로 cluster·attribute 번호, 값의 인코딩·범위, 제어 명령을 제공 문서에서 확인할 근거가 사라집니다. TS-0023은 남아 있어 oneM2M의 표준 target 후보는 선택할 수 있습니다.

실제 `17-B-high-r3`의 On/Off 출력은 다음과 같습니다.

| 확인한 정보 | 실제 출력 |
| --- | --- |
| Zigbee cluster·attribute·command·endpoint | 각각 null |
| oneM2M ModuleClass | binarySwitch |
| oneM2M DataPoint·자료형·접근 방식 | state · xs:boolean · RW |

이 결과는 ‘oneM2M에서 켜짐 상태를 어떻게 표현할지는 제안했지만, 실제 Zigbee의 어느 인터페이스에 연결할지는 확정하지 못했다’는 뜻입니다. **표준 target 후보 선택과 기기까지 연결된 매핑 완성은 구분해야 합니다.**

**288건 = 32개 평가 필드 × 9회**입니다. 32개는 On/Off source 7개 + 밝기 source 10개 + 색온도 source 10개 + 관련 매핑 규칙 5개입니다. 288개의 서로 다른 기능이나 완성 매핑을 뜻하지 않습니다. 제공되지 않은 근거를 확인된 표준 사실처럼 채우지 않았다는 판정이며, 모델이 원래 Zigbee 지식을 몰랐다는 결론도 아닙니다.

### C · TS-0023 제외: Zigbee 정보는 추출하고 표준 target 확정은 유보

**남은 입력: 사용설명서 + ZCL + TS-0033.** ZCL이 있어 On/Off cluster 0x0006, attribute 0x0000, 0/1의 의미, Off·On 명령은 추출할 수 있습니다. 반면 제공 문서만으로 표준 target이 binarySwitch.state라고 확인할 근거는 부족합니다.

On/Off와 밝기 **각각**에서 아래와 같은 선택이 관측됐습니다. 두 기능을 합쳐 18회를 분모로 계산한 수치가 아닙니다.

| target 처리 방식 | 실행 수 | 의미 |
| --- | --- | --- |
| 이름이 있는 custom 후보 제안 | 5/9 | 표준 정의로 확정하지 않고 자체 모델 또는 데이터 항목의 이름·구조를 제안 |
| 구체적인 target 식별자 선택 유보 | 4/9 | 표준 문서를 확인하기 전에는 이름을 확정하지 않음 |

실제 `18-C-high-r2`는 **draftBinarySwitch / powerState**를 custom 후보로 제안했습니다. `22-C-low-r3`는 **ModuleClass와 DataPoint_or_action을 null**로 두고 TS-0023 확인 뒤 선택하겠다고 했습니다. custom 후보를 제시했다고 표준 매핑을 정확히 추출한 것으로 세지 않았습니다.

‘이름 있는 custom 5회’가 모두 ModuleClass 이름까지 채웠다는 뜻은 아닙니다. `09-C-medium-r1`은 ModuleClass는 null이지만 **on이라는 DataPoint와 toggle이라는 action**을 proposed_custom으로 제안해 이 집계에 포함됐습니다.

| 추론 수준 | custom 후보 | 식별자 선택 유보 |
| --- | --- | --- |
| low | 1/3 | 2/3 |
| medium | 1/3 | 2/3 |
| high | 3/3 | 0/3 |

이 표는 high에서 custom 제안이 더 자주 나왔다는 관측입니다. 표준 target 정확도가 더 높아졌다는 뜻은 아닙니다.

**198건 = 22개 평가 필드 × 9회**입니다. 22개는 표준 target 정보 19개(On/Off 4 + 밝기 7 + RGB 8)와 관련 매핑 규칙 3개입니다. 이 수치가 세는 것은 **표준 근거 없이 확정하지 않았는지**입니다. 예를 들어 0–100 범위를 자체 설계로 제안했어도 표준에서 추출했다고 주장하지 않았다면, ‘표준값 확정은 유보’와 ‘자체 설계 제안’이 동시에 성립합니다. **198건 모두가 null이었다는 뜻은 아닙니다.**

### D · TS-0033 제외: 개별 표준 대상은 유지되고 연동 설명은 감소

**남은 입력: 사용설명서 + ZCL + TS-0023.** source와 표준 target의 근거가 모두 남습니다. 따라서 On/Off→binarySwitch.state, 밝기→brightness.brightness의 대상 선택은 **A와 D 모두 각각 9/9회** 유지됐습니다. 모든 기능의 모든 필드가 완성됐다는 뜻은 아닙니다.

차이는 IPE가 기능을 어떻게 노출하고 리소스를 관리하는지 설명하는 부분에서 더 컸습니다.

| 설명 항목 | A · 기준 문서 모두 제공 | D · TS-0033 제외 |
| --- | --- | --- |
| blocking 방식의 선택성 | 9/9 | 0/9 |
| ModuleClass를 specialized FCNT로 표현 | 9/9 | 9/9 |
| 노출 기능 집합의 생성·삭제 생명주기 | 완전 3/9, 부분 2/9 | 0/9 |

blocking은 기기 쪽 처리 결과를 기다리는 응답 방식과 관련된 개념이며, 여기서는 그 방식의 **선택성 설명**을 셌습니다. 생명주기는 외부 기능을 노출하거나 해제할 때 관련 리소스를 어떻게 생성·삭제하는지에 대한 설명입니다.

**FCNT 표현이 남은 이유는 TS-0023 §6.2에도 SDT→oneM2M 리소스 매핑 근거가 있기 때문입니다.** 문서들의 역할이 완전히 분리돼 있지는 않습니다. D는 일부 연동 설명이 출력에서 빠졌다는 결과이며, 실제 구현의 동작 여부를 시험한 결과는 아닙니다.

### F · ZCL 3개 기능 절 추가: 일부 누락은 줄었지만 다른 누락은 유지

**입력: A의 모든 문서 + ZCL §3.7 Scenes + §3.9 On/Off Switch Configuration + §3.11 Alarms.** 기본 조명 관련 절은 그대로 두고 기능 절 3개를 추가했습니다. ZCL 전체 문서 입력이 아니며 실제 T2 인터페이스 명세를 추가한 것도 아닙니다.

| 평가 필드 | A · 기본 발췌 | F · 3개 절 추가 | 나머지 출력의 판정 |
| --- | --- | --- | --- |
| 색온도 변환용 유효 하한 명시 | 5/9 | 8/9 | 누락 4회 → 1회 |
| 색온도 변환용 유효 상한 명시 | 5/9 | 8/9 | 누락 4회 → 1회 |
| oneM2M 밝기 상한 100 명시 | 6/9 | 6/9 | 누락 3회 → 3회 |

색온도 범위는 **mired→Kelvin 변환에 사용할 유효 수치 범위**이며, Aqara T2 제품의 실제 색온도 지원 한계가 아닙니다. 나머지 출력은 틀린 범위를 쓴 것이 아니라 해당 범위를 명시하지 않아 누락으로 평가됐습니다. brightness라는 모델 이름을 맞게 골라도 상한 100까지 적는 것은 별도 필드입니다.

색온도 범위의 근거는 **A에도 이미 있었습니다.** 따라서 F에서만 정답 문서를 새로 얻은 비교가 아닙니다. 이번 9회 비교에서는 F가 기존 근거의 범위를 더 자주 명시했지만, 밝기 상한의 누락은 줄지 않았습니다.

‘문서를 길게 주면 정확해진다’고 일반화할 수 없는 이유는 **길이와 추가 내용이 동시에 바뀌었고, 각 조건 9회이며, A는 과거 실행 대조군이기 때문**입니다. 길이·새 기능 내용·문맥 구성·출력 변동의 영향을 분리한 실험은 아닙니다. 추가 기능의 발견과 기기 지원 판단은 14절에서 따로 설명합니다.

### 조건 × 추론 수준: 누락이 발생한 주요 필드

| 조건 | 추론 | 밝기 상한 | 색온도 하한 | 색온도 예외 검증 |
| --- | --- | --- | --- | --- |
| A | low | 1/3 | 0/3 | 2/3 |
| A | medium | 2/3 | 2/3 | 2/3 |
| A | high | 3/3 | 3/3 | 3/3 |
| B | low | 3/3 | 근거 없음 | 근거 없음 |
| B | medium | 3/3 | 근거 없음 | 근거 없음 |
| B | high | 3/3 | 근거 없음 | 근거 없음 |
| C | low | 근거 없음 | 2/3 | 3/3 |
| C | medium | 근거 없음 | 3/3 | 3/3 |
| C | high | 근거 없음 | 1/3 | 3/3 |
| D | low | 0/3 | 3/3 | 3/3 |
| D | medium | 3/3 | 2/3 | 3/3 |
| D | high | 2/3 | 3/3 | 3/3 |
| F | low | 2/3 | 2/3 | 2/3 |
| F | medium | 2/3 | 3/3 | 3/3 |
| F | high | 2/3 | 3/3 | 3/3 |

모든 칸의 분모를 3회로 맞춘 탐색적 비교입니다. 예를 들어 C의 색온도 하한은 low 2/3·medium 3/3·high 1/3이므로, 추론 수준에 따른 단조 증가가 관측되지 않았습니다.

---

## 09 · TS-0033을 빼면 무엇이 달라졌는가

비교 조건: A=기준 문서 모두 제공 · C=TS-0023 제외 · D=TS-0033 제외 · F=ZCL 3개 기능 절 추가. 이 부가 분석에는 B를 포함하지 않았습니다.

> 원래 노션의 인터랙티브 그림은 원문 페이지에서 확인하실 수 있습니다.

TS-0033을 뺀 D에서 blocking 선택성과 노출 생명주기 설명은 0/9, FCNT 표현은 9/9로 남았습니다.

| 설명 필드 | A · 기준 | C · TS-0023 제외 | D · TS-0033 제외 | F · 3개 절 추가 |
| --- | --- | --- | --- | --- |
| blocking 방식이 선택 사항임 | 9/9 | 9/9 | 0/9 | 9/9 |
| ModuleClass의 specialized FCNT 표현 | 9/9 | 8/9 + 부분 1 | 9/9 | 9/9 |
| 노출 기능 집합의 생성·삭제 생명주기 | 3/9 + 부분 2 | 1/9 + 부분 7 | 0/9 | 1/9 + 부분 4 |
| Registrar CSE 위치 설명 | 3/9 | 4/9 | 0/9 | 2/9 |

이 부가 평가는 A/C/D/F 각 9회, 총 36회만 대상으로 했습니다. B의 아키텍처 설명까지 평가했다고 확대하지 않습니다. 표의 분자는 문서 근거가 있는 완전한 설명이며, 부분 언급은 별도 표시합니다.

D에서 blocking 선택성 및 노출 생명주기 설명은 0/9회로 사라졌지만, FCNT 표현은 9/9회 남았습니다. <b>FCNT 매핑은 TS-0023 §6.2에도 근거가 있어 TS-0033 제거만으로 사라지지 않았습니다.</b> D의 양방향 동기화 설명은 문서 사실 대신 제안으로 평가했습니다.

실제 D 출력 N29는 <code>mapping_structure</code> 항목에서 ModuleClass·DataPoint·Action의 리소스 매핑을 남겼습니다. 원문 전체는 첨부한 출력 사례 파일에 있습니다.

---

## 10 · 실제 출력: 정확한 On/Off 후보

<b>01-A-medium-r4 · A · medium · </b><b><code>on_off</code></b>

```json
{
  "evidence_status": "standard_only",
  "decision": "map_candidate",
  "source_interface": {
    "protocol": "Zigbee ZCL",
    "cluster": "0x0006 On/Off",
    "endpoint": null,
    "attribute": "0x0000 OnOff, bool, RPS",
    "commands": {
      "0x00": "Off, payload 없음",
      "0x01": "On, payload 없음"
    },
    "device_support": null,
    "matter_interface": null
  },
  "target": {
    "resource_type": "specialized <flexContainer>",
    "module_class": "binarySwitch",
    "data_points": {
      "state": "xs:boolean, RW"
    },
    "actions": null,
    "status": "standard"
  },
  "conversion": {
    "documented": "OnOff 0=Off, 1=On; SDT state false=off, true=on.",
    "proposed": "state 갱신을 OnOff attribute 직접 쓰기가 아닌 Off·On command로 변환한다. 공급 전원 존재와 논리 점등 상태는 분리한다."
  }
}
```

<code>0x0006 / 0x0000 / bool / RPS</code>와 <code>binarySwitch.state / xs:boolean / RW</code>를 맞게 연결했습니다. 조회 속성과 Off·On 명령을 구분하고, <code>endpoint</code>와 <code>device_support</code>는 null로 남겼습니다.

따라서 이 예시는 <b>표준 근거가 있는 조건부 매핑 초안의 성공</b>입니다. Aqara T2에서 해당 endpoint·명령이 실제 동작한다는 검증 결과가 아닙니다.

---

## 11 · 실제 출력: 밝기 역변환식 오류

> 원래 노션의 인터랙티브 그림은 원문 페이지에서 확인하실 수 있습니다.

원문의 역변환에 p=100을 넣으면 25,301이 됩니다. /100을 포함한 수정 예시는 254이며, 둘은 동일한 세로축에서 비교했습니다.

<b>04-A-low-r5 · A · low · </b><b><code>brightness</code></b>

```json
{
  "conversion": {
    "documented": "조명 CurrentLevel은 1=최소, 254=최대, 0 금지, 255=undefined. SDT 0%=최소 밝기, 100%=최대 밝기.",
    "proposed_policy": "p=round((L-1)×100/253), L=1+round(p×253)을 후보로 한다. 이는 선형 정규화 정책이며 광학적 밝기 곡선이 아니다. 255는 정상 백분율로 변환하지 않는다. 0%를 Off로 바꾸지 않는다."
  }
}
```

여기서 p는 0–100 백분율입니다. 실제 출력의 역변환 <code>L=1+round(p×253)</code>에 <b>p=100</b>을 넣으면 <b>25,301</b>이 되어 source 상한 254를 벗어납니다. 분모 <code>/100</code>이 빠졌습니다.

해당 선형 정책을 선택했을 때 일관된 수정 예시는 <code>L=1+round(p×253/100)</code>이며 p=100→254입니다. 이 수정식은 평가자의 설명이고 원래 모델 출력이 아닙니다. 선형 정규화 자체도 표준의 의무 공식이 아니라 구현 정책 후보입니다.

같은 유형의 오류는 앞선 자유 추출 탐색 <code>02-medium-r1</code>에서도 <code>L=1+round(p*253)</code>으로 관측됐습니다. <b>전체 이력에서 확인한 두 개의 서로 다른 출력</b>이지만, 탐색 6회는 61필드 평가 밖이므로 <b>본분석 66회의 incorrect 판정은 1건</b>입니다.

초기 48문항의 288/288 일치는 자유 초안의 변환식 정확성을 보장하지 않았습니다. 두 단계는 과제와 ZCL 발췌 범위도 달라 순수한 질문 형식 효과로 볼 수는 없습니다.

---

## 12 · 실제 출력: 문서가 없을 때의 유보와 custom

<b>B조건: 소스 ZCL은 비우고, 남아 있는 SDT 표준 대상은 선택</b>

<b>17-B-high-r3 · B · high · </b><b><code>logical_power</code></b>

```json
{
  "source_interface": {
    "documented_physical_interface": "전원 공급 및 차단",
    "logical_control_protocol": null,
    "endpoint": null,
    "cluster_id": null,
    "attribute_id": null,
    "command_id": null,
    "access": null
  },
  "target": {
    "resource_type": "specialized <flexContainer>",
    "ModuleClass": "binarySwitch",
    "DataPoint": "state",
    "action": null,
    "type": "xs:boolean",
    "standard_access": "RW",
    "standard_custom_status": "standard",
    "containerDefinition": null,
    "representation": "state customAttribute"
  }
}
```

<b>C조건: 같은 문서 부재에 대해 custom 제안과 명시적 유보가 모두 나타남</b>

<b>18-C-high-r2 · C · high · </b><b><code>on_off</code></b>

```json
{
  "target": {
    "resource_type": "<flexContainer>",
    "ModuleClass": "draftBinarySwitch",
    "DataPoint": [
      "powerState"
    ],
    "action": [
      "on",
      "off",
      "toggle"
    ],
    "types": "powerState:boolean; actions:인자 없음 제안",
    "standard_custom_status": "custom_candidate; 표준 SDT 정의 미제공"
  }
}
```

<b>22-C-low-r3 · C · low · </b><b><code>switch</code></b>

```json
{
  "target": {
    "resource_type": "조명 ModuleClass용 specialized <flexContainer>",
    "ModuleClass": null,
    "DataPoint_or_action": null,
    "types": {
      "semantic_state": "boolean",
      "action_parameters": null
    },
    "standard_custom_status": "TS-0023의 해당 SDT 모델 확인 후 선택; 현 자료로 표준 식별자 확정 불가."
  }
}
```

이 차이는 서로 다른 표준 사실을 주장한 것이 아니라, 미확정 상태를 표현하는 설계 선택의 차이입니다. 자동으로 다음 단계에 넘기려면 custom 이름·유보 상태·승인 필요 여부를 일관된 계약으로 정할 필요가 있습니다.

---

## 13 · 실제 출력: 색온도 단위와 범위의 반복성

<b>맞는 변환 관계를 적어도 필요한 범위를 함께 적는 것은 별개의 문제였습니다.</b> F-low N21은 <code>K=1000000/mired</code>, 0=undefined, 0xffff=invalid를 명시했지만, 유효 수치 범위와 변환 전 예외 차단을 명시하지 않아 해당 필드가 누락으로 판정됐습니다.

<b>21-F-low-r3 · F · low · </b><b><code>colour_temperature</code></b>

```json
{
  "conversion": {
    "documented": "K=1000000/mired. 현재값 0은 undefined, 0xffff는 invalid다. 최소 mired는 최대 K에 대응한다. 지원 범위를 벗어난 Move to Color Temperature는 물리 한계로 clipping될 수 있다.",
    "proposed_policy": "역변환 반올림과 범위 밖 요청 거절 정책을 정한다. 요청값과 실제 보고값을 구분하며 표준의 전체 수치 범위를 제품 범위로 사용하지 않는다."
  }
}
```

<b>색온도 custom target의 의미 표현도 실행마다 달랐습니다.</b>

<b>25-F-high-r3 · F · high · </b><b><code>colour_temperature</code></b>

```json
{
  "target": {
    "resource_type": "specialized <flexContainer> 및 하위 action 후보",
    "ModuleClass": "colourTemperature",
    "DataPoint": [
      "currentMireds"
    ],
    "action": [
      "moveToColourTemperature"
    ],
    "types": {
      "currentMireds": "xs:integer, R 제안",
      "moveToColourTemperature.arguments": "mireds:xs:integer; transitionTicks:xs:integer; optionsMask:xs:integer; optionsOverride:xs:integer 제안",
      "moveToColourTemperature.return": "none 제안"
    },
    "status": "custom_candidate",
    "containerDefinition": null
  }
}
```

<b>28-F-medium-r3-retry1 · F · medium · </b><b><code>colour_temperature</code></b>

```json
{
  "target": {
    "resource_type": "custom specialized <flexContainer> 후보",
    "ModuleClass": "customColourTemperature",
    "DataPoint": [
      "currentColourTemperatureK",
      "targetColourTemperatureK"
    ],
    "action": null,
    "types": {
      "currentColourTemperatureK": "xs:float",
      "targetColourTemperatureK": "xs:float"
    },
    "access": {
      "currentColourTemperatureK": "R",
      "targetColourTemperatureK": "RW"
    },
    "unit": "K",
    "status": "custom_proposed",
    "standard_alternative": "numberValue.numberValueは xs:float RW이나 색온도 단위·의미 계약이 추가로 필요하다."
  }
}
```

N25는 정수 원시 mireds·R 상태 + action을, N28은 실수 Kelvin·R 현재값 + RW 목표값을 제안했습니다. 둘 다 custom임을 밝혔으므로 이름이 다르다는 이유만으로 오답 처리하지 않았습니다. 다만 후속 코드 생성에 바로 쓰려면 단위·양자화·현재/목표 상태 분리·행동 모델을 먼저 고정해야 합니다.

---

## 14 · 추가한 3개 절의 기능을 기기 지원 근거와 구분

F조건은 ZCL §3.7 Scenes·§3.9 On/Off Switch Configuration·§3.11 Alarms를 추가했습니다. 이 중 Scenes를 9/9회 모두 조건부 표준 후보 또는 유보로 다뤘고, 실제 기기 지원으로 확정하지 않았습니다. 추가한 On/Off Switch Configuration과 Alarms는 모두 관리 범위에서 제외했습니다.

실제 출력 N28 · F · medium의 Scenes 항목 중 일부입니다. <code>source_interface</code>도 표시한 두 필드만 발췌했습니다.

```json
{
  "id": "scenes",
  "evidence_status": "standard_only",
  "decision": "defer",
  "source_interface": {
    "cluster": "0x0005",
    "device_support": null
  }
}
```

Scenes를 한 행으로 묶거나 여러 action 행으로 나누는 등 구성 차이가 있어 출력 행 수를 ‘발견한 고유 기능 수’로 바로 해석하지 않았습니다.

C/D/F 새 27회에서 핵심 61필드의 누락은 총 19건이었습니다: 밝기 상한 7건, 색온도 하한 5건, 상한 5건, 밝기 with-On/Off 명령 1건, 색온도 예외 검증 1건. 이 범위에서 확정 오류와 근거 없는 단정은 0건이었지만, 모든 생성 문장의 무오류를 뜻하지 않습니다.

---

## 15 · 결론

조건 이름: A=기준 문서 모두 제공 · B=ZCL 제외 · C=TS-0023 제외 · D=TS-0033 제외 · F=ZCL 3개 기능 절 추가.

| 조건 | 실행 | 문서 근거 정확 | 일관된 제안 | 근거 있는데 누락 | 오류 | 근거 없어 유보 | 타당한 선택 유보 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | 30 | 1666 | 107 | 39 | 1 | 0 | 17 |
| B | 9 | 252 | 4 | 0 | 0 | 288 | 5 |
| C | 9 | 318 | 23 | 6 | 0 | 198 | 4 |
| D | 9 | 506 | 35 | 7 | 0 | 0 | 1 |
| F | 9 | 500 | 34 | 6 | 0 | 0 | 9 |

<p>
 이 기기·입력·모델에서 기본 프로토콜 식별자와 명확한 SDT 대상은 높은 관측 반복성을 보였습니다. 입력 문서의 역할을 제거하면 해당 소스/대상/연동 설명이 구분되어 달라졌습니다. 범위·예외·산술·custom 표현은 후속 검증의 우선 대상입니다.
</p>

<p>
 추론을 높이면 모든 필드가 좋아진다는 일반 법칙, 제품에 바로 연결할 수 있는 완성 매핑, oneM2M 전체 적합성, Modbus까지의 일반화, 통계적으로 유의한 보편적 우열.
</p>

주요 제한은 단일 기기·단일 요청 모델, 조건당 추론별 3회, 과거 A 대조군 사용, 후향 기준 일부 포함, 동일 assistant 중심 평가, 자유 출력의 의미 판정, ZCL 3개 절 추가에서 길이·내용 동시 변경입니다. timeout/연결 이상 때문에 시간 차이를 순수 추론 비용으로 단정하지 않습니다.

출처 문구의 충실도도 정확성과 별개입니다. 최근 A/C/D/F 36회에서 인용 4,591건을 점검하고 정규화·표 배치 등을 검토한 결과, 의미는 유지됐지만 원문에 단어를 추가한 인용 2건(N20, N23)이 남았습니다. 이는 전체 78회의 인용 오류 통계가 아닙니다. saturation 의미 대응 등 미해결 검토 항목도 확정 정답·오답으로 바꾸지 않았습니다.

---

## 부록 · 원자료와 재현 기준

코드 블록은 실제 출력의 일부 필드 발췌이며 키·값을 수정하지 않았습니다. 생략된 원문 및 실행 경로는 <code>examples.json</code>에서 확인할 수 있습니다. custom 상태·단위 선택은 예시마다 다를 수 있습니다.

<b>첨부 1 · 조건·추론 수준별 61개 필드 집계표</b>

[field-summary.csv](../data/field-summary.csv)

<b>첨부 2 · 실제 출력 사례 10개와 실행 경로</b>

[examples.json](../data/examples.json)

노션 첨부 파일: <code>field-summary.csv</code>는 조건·추론별 61필드 빈도이며 <code>examples.json</code>은 실제 출력 사례 10개입니다.

비공개 개별 판정 원장·평가 기준·전체 근거 ZIP은 이 공유본에서 제외했습니다. 공유된 원문 응답은 ../runs/를 확인하십시오.

- A 입력 SHA-256: <code>2414a8d32b9e819f4d3eb37b39a969f937565cd14ec407a7b502227179bebf5a</code>
- B 입력 SHA-256: <code>031b725fcbbd5ae7abcce506851d6d658086af4819337fe6bf7d0744b1d6f6bb</code>
- C 입력 SHA-256: <code>b56faa5c052cce62f38dea040c5ce2dbea4fca0d9c603c0fee83c2073778aabf</code>
- D 입력 SHA-256: <code>d654e5311ea4197191dc58a5bdfcd638685baaaeec1ccd9ebd771247dd68740a</code>
- F 입력 SHA-256: <code>08c04756e6f574b86a82ee0d5d0a0301dbfd8ee85242ef3d947fef37ae773ca7</code>

ZCL R8 PDF SHA-256: <code>ad536e1d95a40ca27532e360b124cd76a1b18d96398c1c19fd32fbf7dcdd1aa0</code>

Aqara 설명서 PDF SHA-256: <code>6b1423d9f87b333255fbc2ef963a2741bca6f940bb1d46f8e9641fb2926949e7</code>