# Deployment Script for DigiPic
# Usage: .\run.ps1

$JAVA_HOME = "C:\Program Files\Java\jdk-21"
$CATALINA_HOME = "D:\apache-tomcat-10.1.54"
$APP_NAME = "DigiPic"
$SOURCE_ROOT = $PSScriptRoot
$BUILD_DIR = "$SOURCE_ROOT\build"
$CLASSES_DIR = "$BUILD_DIR\classes"
$WEBAPP_DIR = "$SOURCE_ROOT\src\main\webapp"
$LIB_DIR = "$WEBAPP_DIR\WEB-INF\lib"

# 1. Environment Check
if (-not (Test-Path "$JAVA_HOME\bin\javac.exe")) {
    Write-Error "JDK not found at $JAVA_HOME. Please update the path in run.ps1."
    exit
}
if (-not (Test-Path "$CATALINA_HOME\bin\startup.bat")) {
    Write-Error "Tomcat not found at $CATALINA_HOME. Please update the path in run.ps1."
    exit
}

# 2. Clean and Setup
Write-Host "--- Starting Build Process for $APP_NAME ---" -ForegroundColor Cyan
if (Test-Path $BUILD_DIR) { Remove-Item -Recurse -Force $BUILD_DIR }
New-Item -ItemType Directory -Path $CLASSES_DIR -Force | Out-Null

# 3. Compilation
Write-Host "[1/4] Compiling Java source files..." -ForegroundColor Yellow
$classpath = "$CATALINA_HOME\lib\servlet-api.jar;$CATALINA_HOME\lib\jsp-api.jar;$CATALINA_HOME\lib\el-api.jar"

# Collect all JARs from WEB-INF/lib
if (Test-Path $LIB_DIR) {
    $extraJars = Get-ChildItem -Path $LIB_DIR -Filter *.jar | ForEach-Object { $_.FullName }
    if ($extraJars) { $classpath += ";" + ($extraJars -join ";") }
}

# Collect JSTL from GymPulse (required for compilation if used, and for runtime)
$gymPulseLib = "$CATALINA_HOME\webapps\GymPulse\WEB-INF\lib"
if (Test-Path $gymPulseLib) {
    $jstlJars = Get-ChildItem -Path $gymPulseLib -Filter "jakarta.servlet.jsp.jstl*" | ForEach-Object { $_.FullName }
    if ($jstlJars) { $classpath += ";" + ($jstlJars -join ";") }
}

$javaFiles = Get-ChildItem -Path "$SOURCE_ROOT\src\main\java" -Recurse -Filter *.java | ForEach-Object { $_.FullName }

if (-not $javaFiles) {
    Write-Error "No Java source files found in src/main/java"
    exit
}

& "$JAVA_HOME\bin\javac.exe" -d $CLASSES_DIR -cp $classpath -encoding UTF-8 $javaFiles
if ($LASTEXITCODE -ne 0) {
    Write-Host "!!! Compilation failed. Check the errors above. !!!" -ForegroundColor Red
    exit
}
Write-Host "Success: Compilation completed." -ForegroundColor Green

# 4. Assemble Deployment Folder
Write-Host "[2/4] Assembling deployment structure..." -ForegroundColor Yellow
$deployDir = "$BUILD_DIR\deploy"
New-Item -ItemType Directory -Path $deployDir -Force | Out-Null
Copy-Item -Path "$WEBAPP_DIR\*" -Destination $deployDir -Recurse -Force

# Copy classes
$classesTarget = "$deployDir\WEB-INF\classes"
New-Item -ItemType Directory -Path $classesTarget -Force | Out-Null
Copy-Item -Path "$CLASSES_DIR\*" -Destination $classesTarget -Recurse -Force

# Ensure JSTL is in the deployment lib (Tomcat doesn't provide it)
$libTarget = "$deployDir\WEB-INF\lib"
if (-not (Test-Path $libTarget)) { New-Item -ItemType Directory -Path $libTarget -Force | Out-Null }
if ($jstlJars) {
    foreach ($jar in $jstlJars) {
        Copy-Item -Path $jar -Destination $libTarget -Force
    }
}

# 5. Deploy to Tomcat
Write-Host "[3/4] Deploying to Tomcat..." -ForegroundColor Yellow
$targetAppDir = "$CATALINA_HOME\webapps\$APP_NAME"
if (Test-Path $targetAppDir) {
    Write-Host "Removing old deployment..." -ForegroundColor Gray
    Remove-Item -Recurse -Force $targetAppDir
}
Copy-Item -Path $deployDir -Destination $targetAppDir -Recurse -Force
Write-Host "Success: Deployed to $targetAppDir" -ForegroundColor Green

# 6. Start Tomcat
Write-Host "[4/4] Restarting Tomcat server..." -ForegroundColor Yellow
Write-Host "Stopping Tomcat (if running)..." -ForegroundColor Gray
$env:CATALINA_HOME = $CATALINA_HOME
$env:JAVA_HOME = $JAVA_HOME
& "$CATALINA_HOME\bin\shutdown.bat" 2>$null
Start-Sleep -Seconds 2

Write-Host "Starting Tomcat..." -ForegroundColor Gray
Start-Process "$CATALINA_HOME\bin\startup.bat" -WindowStyle Minimized

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " Deployment Complete!" -ForegroundColor Green
Write-Host " Application URL: http://localhost:8085/$APP_NAME" -ForegroundColor Cyan
Write-Host "====================================================`n" -ForegroundColor Cyan
