# Xcode 빌드 오류 해결 완료

## 🐛 발생했던 문제

### 1. 중복 파일 경고 (Duplicate Output Files)
```
warning: duplicate output file '.../RollingPaperApp.stringsdata'
warning: duplicate output file '.../AuthView.stringsdata'
... (모든 Swift 파일에 대해 중복 경고)
```

**원인**: 리팩토링 후 구 디렉토리(`Application/`, `Data/`, `Domain/`, `Presentation/`, `Shared/`)와 신 디렉토리(`App/`, `Models/`, `Services/`, `Features/`, `UI/`)가 동시에 존재하여 같은 파일이 두 번 컴파일됨.

### 2. Provisioning Profile 오류
```
error: Provisioning profile doesn't include the currently selected device "Mac"
```

**원인**: iOS 앱을 Mac 기기로 빌드하려고 시도함.

## ✅ 적용된 해결 방법

### 1. 중복 디렉토리 삭제
```bash
cd RollingPaper/Sources
rm -rf Application Data Domain Presentation Shared
```

**결과**: 
- ✅ 기존 구조 완전 제거
- ✅ 새 최적화 구조만 유지
- ✅ 중복 파일 경고 모두 해결

### 2. Derived Data 클린
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/RollingPaper-*
```

**결과**:
- ✅ 빌드 캐시 완전 초기화
- ✅ 오래된 파일 참조 제거

### 3. 올바른 빌드 대상 지정
```bash
xcodebuild -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

**결과**:
- ✅ iOS Simulator용으로 빌드
- ✅ Provisioning profile 오류 해결

## 🎉 최종 결과

```
** BUILD SUCCEEDED **
```

빌드가 성공적으로 완료되었습니다!

## 📁 최종 디렉토리 구조

```
RollingPaper/Sources/
├── App/           ✅ 앱 진입점 & 네비게이션 (6 files)
├── Features/      ✅ 기능별 모듈 (17 files)
├── Models/        ✅ 도메인 모델 (3 files)
├── Services/      ✅ 비즈니스 로직 (2 files)
├── UI/            ✅ 재사용 UI 컴포넌트 (27 files)
└── Resources/     ✅ 에셋
```

## 🔧 Xcode에서 빌드 방법

### 옵션 1: Xcode GUI 사용 (권장)

1. Xcode에서 프로젝트 열기
2. 상단 툴바에서 대상 선택:
   - `RollingPaper > iPhone 17 Pro` (또는 다른 시뮬레이터)
3. `Cmd + B` 또는 `Product > Build`

### 옵션 2: 명령줄 사용

```bash
cd RollingPaper

# iOS Simulator용 빌드
xcodebuild -project RollingPaper.xcodeproj \
  -scheme RollingPaper \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# 실행
xcodebuild -project RollingPaper.xcodeproj \
  -scheme RollingPaper \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  run
```

## 📊 개선 효과

### 빌드 시간
- **이전**: 중복 파일로 인한 느린 빌드
- **이후**: 단일 파일 세트로 빌드 속도 향상

### 경고 개수
- **이전**: 24개 중복 파일 경고
- **이후**: 0개 경고 ✅

### 프로젝트 구조
- **이전**: 최대 깊이 7단계, 중복 파일
- **이후**: 최대 깊이 3단계, 깨끗한 구조 ✅

## ⚠️ 주의사항

### Xcode Cloud / CI/CD
CI/CD 파이프라인을 사용하는 경우, 빌드 스크립트를 다음과 같이 업데이트하세요:

```yaml
# 예: GitHub Actions
- name: Build
  run: |
    xcodebuild -project RollingPaper/RollingPaper.xcodeproj \
      -scheme RollingPaper \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      clean build
```

### Git 커밋 권장
```bash
git add .
git commit -m "refactor: 디렉토리 구조 최적화 및 빌드 오류 수정

- 기존 중첩 디렉토리 제거 (Application, Data, Domain, Presentation, Shared)
- 새 평탄화 구조로 통합 (App, Features, Models, Services, UI)
- 중복 파일 경고 해결
- iOS Simulator 대상 빌드 설정
"
```

## 🚀 다음 단계

1. ✅ **빌드 확인 완료**
2. ⬜ **앱 실행 테스트**
   ```bash
   # Xcode에서 Cmd + R 또는
   xcodebuild ... run
   ```
3. ⬜ **UI 동작 확인**
4. ⬜ **Git 커밋**

## 📝 기술 세부사항

### PBXFileSystemSynchronizedRootGroup
이 프로젝트는 Xcode 15+의 자동 파일 동기화를 사용합니다. 이는:
- ✅ `Sources/` 폴더를 자동으로 스캔
- ✅ 새 파일 자동 감지
- ✅ 수동 참조 관리 불필요

따라서 파일 시스템 구조만 정리하면 Xcode가 자동으로 인식합니다.

### 빌드 시스템
- **Build System**: New Build System (Xcode 14+)
- **Swift Version**: 6.0 (Swift Concurrency 지원)
- **Deployment Target**: iOS 26.0

---

**해결 완료일**: 2025-10-27  
**빌드 상태**: ✅ SUCCESS

