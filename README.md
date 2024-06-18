# 🚧Bulldozer
## OCR을 활용한 청소년 전용 도박 사이트 차단 앱 서비스 [팀명 : 불도저(불법도박저지)]
<br>

## 🚦 서비스 소개
* 수정중
<br>

## 🗓 프로젝트 기간
**2024.04.30 ~ 2024.06.20**
<br>
<br>
## 🛠 주요기능
### 이용자
* 백그라운드 앱 실행으로 브라우저 이용 시, 도박사이트 차단
* 미등록 유해 사이트 신고 기능
* 앱 기능 on/off 시 or 유해사이트 판별 시 보호자에게 문자 알림 기능
### 관리자
* 이용자 관리(이용자 목록, 선택 시 차단 횟수와 URL) 
* URL 관리(URL 목록들과 차단 횟수 및 최초 등록날짜)
* 유해 사이트 단어사전 열람 및 단어 추가 기능
* 신고된 미등록 유해 사이트 재판별 기능
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
        </td>
    </tr>
</table>

<br>

## ⚙ 시스템 아키텍처
![시스템아키텍처](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/634ba724-702f-42e2-bdc5-3c069e093ffe)



<br>

## 📝 유스케이스
![유스케이스](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/d02aafb3-f793-42c2-a855-eca106346561)



<br>

## 〰 서비스 흐름도
![화면설계서 플로우 차트 drawio](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/d91c8e90-541a-4842-8e93-01b2dc0a2d66)



<br>

## 💡 화면구성
<br>
<br>

### 🖥 이용자 화면
<br>

* 이용자 메인화면(백그라운드 앱 실행 off/on)
![이용자off](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/fb249e0f-ba3e-45a2-8e75-e81f421ab98f)
![이용자on](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/9dbdec00-1882-4e54-a409-2b172dfdd4b8)

<br>

------------------------------------------------------------------------------------------
<br>

### 🖥 관리자 화면
<br>

* 관리자 메인 화면
  ![관리자 메인](https://github.com/2021-SMHRD-KDT-AI-17/Bulldozer/assets/157380359/df5b5d75-a058-4df6-95f9-2f709e2d29ad)

<br>

#### 🖱 공구함 게시글 상세


<br>

#### 🖱 공구함 게시글 수정


<br>

#### 🖱 게시글 내 참여하기 - 채팅방


<br>
------------------------------------------------------------------------------------------

<br>

### 🖥 우리동네 게시판 화면
<br>
<br>


<br>


  

<br>

------------------------------------------------------------------------------------------
<br>

### 🖥 POP - 검색하기 화면
<br>
<br>





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



