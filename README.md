# 🚧Bulldozer
팀명 : 불도저(불법도박저지)
팀원 : 정두연, 고현우, 김동준, 나유정, 정재원, 홍창민
<br>
<br>

## 🚦 서비스 소개
### EasyOCR과 GoogleVision을 활용한 청소년 전용 도박 사이트 차단 앱 서비스
* 제안배경
  1. 청소년 사이버도박 증가(2023.0925 ~ 2024.05.31동안 청소년 사이버도박 검거현황 1035명)
  2. 법적으로 규제가 되어있으나 관리/감독이 되지 않아 보호를 받는 청소년 이용자 비중의 괴리
* 필요성
  1. 캡차/관문사이트/가입코드 등 도박사이트의 기술적 다변화
  2. 브라우저 검색을 통해 쉽게 접할 수 있는 총판 방식의 불법 웹 사이트 코드 판매
  3. 중학생이 도박사이트를 만들고 운영할만큼 코딩에 익숙해진 사회

<br>

### 차별성
* 만 12세로 제한되는 기존 서비스들과 다르게 이용자의 연령에 국한되지 않음
* 기존 정적 분석이 아닌 동적분석을 활용하여 정확도를 향상시키고 도박키워드를 효과적으로 검출함
* 유해사이트 수동등록, 방송통신위원회가 지정한 URL이 아닌 이용자가 웹 사이트 접근 시, OCR 분석을 통해 유해사이트를 판별

<br>
<br>

## 🗓 프로젝트 기간
**2024.04.30 ~ 2024.06.20**

<br>
<br>

## 🛠 주요기능
### 📱 이용자
* 백그라운드 앱 실행으로 브라우저 이용 시, 도박사이트 차단 기능
* 미등록 유해 사이트 신고 기능
* 앱 기능 on/off 시 or 유해사이트 판별 시 보호자에게 문자 알림 기능
### ⚙ 관리자
* 이용자 관리 기능(이용자 목록, 선택 시 차단 횟수와 URL) 
* URL 관리 기능(URL 목록들과 차단 횟수 및 최초 등록날짜)
* 유해 사이트 단어사전 열람 및 단어 추가 기능
* 신고된 미등록 유해 사이트 재판별 기능
<br>
<br>

## ⚔ 기술스택
<table>
    <tr>
        <th>구분</th>
        <th>내용</th>
    </tr>
    <tr>
        <td>Language</td>
        <td>
            <img src="https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=Kotlin&logoColor=white"/>
            <img src="https://img.shields.io/badge/dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
            <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=Python&logoColor=white"/> 
        </td>
    </tr>
    <tr>
        <td>Front-end/Back-end</td>
        <td>
            <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
        </td>
    </tr>
    <tr>
        <td>IDE</td>
        <td>
          <img src="https://img.shields.io/badge/Android Studio-3DDC84?style=for-the-badge&logo=Android Studio&logoColor=white"/>
          <img src="https://img.shields.io/badge/VSCode-007ACC?style=for-the-badge&logo=VisualStudioCode&logoColor=white"/>
          <img src="https://img.shields.io/badge/Jupyter-F37626?style=for-the-badge&logo=Jupyter&logoColor=white"/>
        </td>
    </tr>
    <tr>
        <td>Server</td>
        <td>
          <img src="https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=Flask&logoColor=white"/>
          <img src="https://img.shields.io/badge/ngrok-1F1E37?style=for-the-badge&logo=ngrok&logoColor=white"/> 
        </td>
    </tr>
    <tr>
        <td>Database</td>
        <td>
            <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=MySQL&logoColor=white"/> 
        </td>
    </tr>
    <tr>
         <td>Model</td>
         <td>
             <img src="https://img.shields.io/badge/EasyOCR-0099B0?style=for-the-badge&logo=EasyOCR&logoColor=white"/>
             <img src="https://img.shields.io/badge/opencv-5C3EE8?style=for-the-badge&logo=opencv&logoColor=white"/> 
         </td>
    </tr>
    <tr>
        <td>Collaboration</td>
        <td>
            <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=Git&logoColor=white"/>
            <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=GitHub&logoColor=white"/>
            <img src="https://img.shields.io/badge/Miro-050038?style=for-the-badge&logo=Miro&logoColor=white"/>
        </td>
    </tr>
      <tr>
        <td>Library</td>
        <td>
            <img src="https://img.shields.io/badge/openai-412991?style=for-the-badge&logo=openai&logoColor=black">
            <img src="https://img.shields.io/badge/Naver Open API-03C75A?style=for-the-badge&logo=Naver Open API&logoColor=white">
            <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
            <img src="https://img.shields.io/badge/Google Vision-4285F4?style=for-the-badge&logo=Google Vision&logoColor=white"/>
            <img src="https://img.shields.io/badge/rive-1D1D1D?style=for-the-badge&logo=rive&logoColor=white"/>
            <img src="https://img.shields.io/badge/lottie-66DEB1?style=for-the-badge&logo=lottie&logoColor=white"/>
        </td>
    </tr>
</table>

<br>

## ⚙ 시스템 아키텍처
![시스템아키텍처](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/309d96f4-349c-4f92-ae6d-84f3948aef5d)



<br>

## 📝 유스케이스
![유스케이스](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/d02aafb3-f793-42c2-a855-eca106346561)



<br>

## 〰 서비스 흐름도
![화면설계서 플로우 차트 drawio](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/d91c8e90-541a-4842-8e93-01b2dc0a2d66)



<br>

## 🎲 ER 다이어그램
![ER 다이어그램](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/2601d79a-15bc-479a-914b-e72952b2082a)



<br>

## 👾 모델 선택 및 유해사이트 판단 과정

### ✅모델 선택
![실전프로젝트-발표-017](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/7edf31e2-a02f-4cc2-b4c8-d4ee9532d6a8)

<br>

### 💬 유해사이트 판단 과정
![차단과정](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/ae82205e-f55f-4b33-99b0-ed0b293b4449)

#### 불법 도박사이트 판단 예시
![022](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/22f73682-ed0a-483e-b478-490687e09c84)
![025](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/2d8de9ad-09a3-48b2-aadd-6edfdd078a47)



<br>
<br>

## 💻 화면구성
<br>


### 📱 시작 화면
<br>

* 로그인 화면
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/6320963f-7e8a-454e-b482-dac9d35f4ae8" height="666" width="324"/>

<br>
<br>

* 회원가입 화면
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/39045b15-ee2b-4df1-8112-47096371fbe7" height="666" width="324"/>

<br>
<br>
<br>

### 📱 이용자 화면
<br>

* 이용자 메인화면(백그라운드 앱 실행 off/on)
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/fb249e0f-ba3e-45a2-8e75-e81f421ab98f" height="666" width="324"/>
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/9dbdec00-1882-4e54-a409-2b172dfdd4b8" height="666" width="324"/>

<br>
<br>

* 불법 도박사이트 접근 시
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/9a05bcd2-b972-4631-b16e-b26711d4a650" height="666" width="324"/>
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/d32f2618-f924-4126-b699-49fa99ac1627" height="468" width="239"/>


<br>
<br>

------------------------------------------------------------------------------------------
<br>

### 📱 관리자 화면
<br>

#### 관리자 메인 화면

<br>
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/df5b5d75-a058-4df6-95f9-2f709e2d29ad" height="666" width="324"/>

<br>

* 관리자 기능 이동 탭
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/65bb4cc4-dc32-4185-ac77-cbd063d97f1a" height="666" width="324"/>

<br>
<br>

#### 회원 목록
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/844abbeb-bb01-4073-a7ff-5fe197c7320c" height="666" width="324"/>

<br>
<br>

#### 유해사이트 목록
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/b919dc1c-7d66-4839-aba0-4c4383d4e96f" height="666" width="324"/>

<br>
<br>

#### 단어사전
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/3d39acf1-cef2-4acf-ac97-d2391770164a" height="666" width="324"/>
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/31202eff-6746-4dcb-9e68-35ad26ae3acf" height="666" width="324"/>

<br>
<br>

------------------------------------------------------------------------------------------
<br>

### 📱 신고 화면

<br>

#### 이용자 - 유해 사이트 신고
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/45a22bbf-24ec-4150-89e4-c0eecf8de98a" height="666" width="324"/>
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/ba822506-336d-4eca-9066-3c1fc429e9ef" height="666" width="324"/>

<br>
<br>


#### 관리자 - 신고 게시판
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/ebc68f32-3d27-4bac-a49d-10548e7b71fa" height="666" width="324"/>

<br>

#### 관리자 - 유해 사이트 재판별
<img src="https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/e224974c-5879-48af-868a-12855d432357" height="666" width="324"/>





<br>

------------------------------------------------------------------------------------------
<br>


<br>
<br>

## 🥊 트러블슈팅
![실전프로젝트-발표-030](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/0d51b4be-186b-44fc-8ea3-b7bae52ed449)
<br>
<br>


## 👨‍👩‍👧‍👦 팀원역할
![002](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/0658efe3-2b98-41af-a99f-e67fddb251f8)


<br>
<br>

## 📚 참고문헌 및 출처
![001](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/95c3fadb-a080-4d9e-8c9f-af3a81e76028)

<br>


