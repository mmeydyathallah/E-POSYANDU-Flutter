/*
 * ESP32-C6 Code untuk Aplikasi Posyandu
 * MODE: Real Sensors (HX711 & VL53L0X) + LCD via I2C + BLE
 * DENGAN FITUR MEDIAN FILTER (Stabilisasi Sensor Berat & Jarak)
 * + ELEGANTOTA (OTA Update via WiFi Access Point / Web Browser)
 *
 * Library yang dibutuhkan:
 *   - NimBLE-Arduino (Install via Library Manager)
 *   - Adafruit NeoPixel
 *   - HX711_ADC by Olav Kallhovd atau HX711 by Bogdan Necula
 *   - VL53L0X by Pololu
 *   - LiquidCrystal_I2C
 *   - ElegantOTA (Install via Library Manager: "ElegantOTA")
 *   - AsyncTCP (Install via Library Manager: "AsyncTCP")
 *   - ESPAsyncWebServer (Install via Library Manager: "ESPAsyncWebServer")
 *
 * ============================================================
 * PINOUT ESP32-C6
 * ============================================================
 *  I2C SDA  →  GPIO 5 (VL53L0X & LCD)
 *  I2C SCL  →  GPIO 6 (VL53L0X & LCD)
 *  HX711 DOUT → GPIO 12
 *  HX711 SCK  → GPIO 13
 *  RGB LED  →  GPIO 8 (WS2812 Built-in)
 *
 * ============================================================
 * CARA PAKAI OTA (ElegantOTA via Access Point)
 * ============================================================
 *  1. Upload firmware ini via kabel (pertama kali)
 *  2. ESP32 akan membuat hotspot WiFi sendiri (lihat AP_SSID di bawah)
 *  3. Sambungkan HP/Laptop ke WiFi hotspot ESP32 tersebut
 *  4. Buka browser: http://23.23.23.1/update
 *  5. Upload file .bin firmware baru langsung dari browser!
 *  6. OTA username: admin | password: posyandu (bisa diubah di bawah)
 * ============================================================
 */

#include <Adafruit_NeoPixel.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ElegantOTA.h>
#include <HX711.h>
#include <LiquidCrystal_I2C.h>
#include <NimBLEDevice.h>
#include <VL53L0X.h>
#include <WiFi.h>
#include <Wire.h>

// ==========================================
// KONFIGURASI ACCESS POINT (Hotspot ESP32)
// ==========================================
const char *AP_SSID = "E-Posyandu"; // <-- Nama hotspot ESP32
const char *AP_PASSWORD =
    "Meydy2004"; // <-- Password hotspot (min 8 karakter, kosongkan jika open)

// ==========================================
// KONFIGURASI OTA (Username & Password Web OTA)
// ==========================================
const char *OTA_USERNAME = "meydy";
const char *OTA_PASSWORD = "Meydy2004";
const int OTA_PORT = 80; // Port web server OTA

// ==========================================
// BLE CONFIGURATION
// ==========================================
#define DEVICE_NAME "eposyandu"
#define SERVICE_UUID "12345678-1234-1234-1234-123456789abc"
#define DATA_CHAR_UUID "abcd1234-5678-1234-5678-abcdef012345"
#define COMMAND_CHAR_UUID "abcd1234-5678-1234-5678-abcdef012346"

// ==========================================
// HARDWARE PINS & CONFIG
// ==========================================
#define LED_PIN 8
#define NUMPIXELS 1
#define I2C_SDA 5
#define I2C_SCL 6
#define LOADCELL_DOUT_PIN 12
#define LOADCELL_SCK_PIN 13

// ==========================================
// I2C ADDRESSES
// ==========================================
#define LCD_I2C_ADDRESS 0x27     // LCD 20x4 I2C
#define VL53L0X_I2C_ADDRESS 0x29 // VL53L0X ToF Sensor

// ==========================================
// OBJEK HARDWARE
// ==========================================
Adafruit_NeoPixel pixels(NUMPIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);
HX711 scale;
VL53L0X sensorHeight;
LiquidCrystal_I2C lcd(LCD_I2C_ADDRESS, 20, 4);

// Web Server & ElegantOTA
AsyncWebServer server(OTA_PORT);

// ==========================================
// SENSOR VARIABLES
// ==========================================
// Kalibrasi Berat
float calibration_factor = -7050.0; // Ganti dengan faktor load cell asli Anda
long zero_factor = 0;
float currentWeight = 0.0;

// Kalibrasi Tinggi
float sensor_height_frame = 150.0; // Jarak sensor ke lantai (cm)
float height_offset = 0.0;
float currentHeight = 0.0;

// ==========================================
// GLOBAL
// ==========================================
// EMA Filter Variables
float smoothedWeight = 0.0;
float smoothedHeight = 0.0;
const float alphaWeight = 0.2; // Faktor EMA berat (makin kecil makin halus)
const float alphaHeight = 0.3; // Faktor EMA tinggi

bool hardwareError = false;
bool loadCellReady = false; // Flag: load cell tersambung atau tidak
bool vl53l0xReady = false;  // Flag: lidar tersambung atau tidak
bool apActive = false;      // Flag: Access Point aktif atau tidak

NimBLEServer *pServer = nullptr;
NimBLECharacteristic *pDataCharacteristic = nullptr;
NimBLECharacteristic *pCommandCharacteristic = nullptr;

bool deviceConnected = false;
bool oldDeviceConnected = false;
unsigned long lastReadTime = 0;
unsigned long lastSendTime = 0;
unsigned long lastLCDTime = 0;
const unsigned long readInterval = 100;  // Baca sensor setiap 100ms
const unsigned long sendInterval = 1000; // Kirim data ke BLE tiap 1 detik
const unsigned long lcdInterval = 500;   // Refresh LCD tiap 500ms

String bleMacAddress = ""; // MAC address ESP32 untuk ditampilkan di LCD
String apIPAddress = "";   // IP Address AP untuk OTA (defaultnya 192.168.4.1)

// OTA progress tracking
bool otaInProgress = false;
unsigned long otaStartTime = 0;

// ==========================================
// LCD HELPER
// ==========================================
void updateLCD(String status) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("E-POSYANDU " + status);

  lcd.setCursor(0, 1);
  lcd.print("Berat: ");
  lcd.print(currentWeight, 2);
  lcd.print(" kg");

  lcd.setCursor(0, 2);
  lcd.print("Tinggi: ");
  lcd.print(currentHeight, 1);
  lcd.print(" cm");

  lcd.setCursor(0, 3);
  if (otaInProgress) {
    lcd.print("OTA: Updating...    ");
  } else if (deviceConnected) {
    lcd.print("BLE: Terhubung      ");
  } else if (apActive) {
    // Tampilkan IP OTA di baris 3 saat AP aktif
    String ipStr = "OTA: " + apIPAddress;
    lcd.print(ipStr.substring(0, 20)); // Potong agar muat 20 char
  } else {
    lcd.print(bleMacAddress);
  }
}

void updateLCDOTA(int progress) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("** OTA UPDATE **    ");
  lcd.setCursor(0, 1);
  lcd.print("Progress: ");
  lcd.print(progress);
  lcd.print("%        ");
  lcd.setCursor(0, 2);
  lcd.print("Jangan cabut daya!  ");
  lcd.setCursor(0, 3);
  lcd.print("IP: " + apIPAddress);
}

// ==========================================
// BLE CALLBACKS
// ==========================================
class ServerCallbacks : public NimBLEServerCallbacks {
  void onConnect(NimBLEServer *pServer, NimBLEConnInfo &connInfo) override {
    deviceConnected = true;
    Serial.println("✅ Client connected!");
    updateLCD("READY");
  }

  void onDisconnect(NimBLEServer *pServer, NimBLEConnInfo &connInfo,
                    int reason) override {
    deviceConnected = false;
    Serial.println("❌ Client disconnected!");

    // Restart advertising agar bisa di-scan ulang
    NimBLEDevice::startAdvertising();
    Serial.println("📡 Advertising restarted...");

    delay(500);
    updateLCD("WAITING");
  }
};

class CommandCallbacks : public NimBLECharacteristicCallbacks {
  void onWrite(NimBLECharacteristic *pCharacteristic,
               NimBLEConnInfo &connInfo) override {
    std::string value = pCharacteristic->getValue();
    if (value.length() > 0) {
      String cmd = String(value.c_str());
      cmd.trim();
      Serial.print("📨 Command received: ");
      Serial.println(cmd);

      if (cmd == "tare") {
        if (loadCellReady) {
          Serial.println("   → Tare command (reset berat ke 0)");
          scale.tare(10);
          lcd.setCursor(0, 3);
          lcd.print("   Tare Selesai!    ");
          delay(1000);
        } else {
          Serial.println("   → Tare GAGAL: Load cell tidak tersambung");
        }
      } else if (cmd == "calibrate") {
        Serial.println("   → Calibrate command");
      }
    }
  }
};

// ==========================================
// MEDIAN FILTER HELPERS
// ==========================================
float getMedianWeight() {
  float readings[5];

  for (int i = 0; i < 5; i++) {
    readings[i] = scale.get_units(1); // Baca per sampel
  }

  // Mengurutkan dengan Bubble Sort
  for (int i = 0; i < 4; i++) {
    for (int j = i + 1; j < 5; j++) {
      if (readings[i] > readings[j]) {
        float temp = readings[i];
        readings[i] = readings[j];
        readings[j] = temp;
      }
    }
  }

  // Mengembalikan nilai di tengah (median)
  return readings[2];
}

float getMedianHeight() {
  float readings[5];

  for (int i = 0; i < 5; i++) {
    // Membaca dari Continuous Mode (Burst read) jauh lebih cepat
    uint16_t dist = sensorHeight.readRangeContinuousMillimeters();
    if (sensorHeight.timeoutOccurred()) {
      Serial.println("❌ VL53L0X I2C Timeout!");
      hardwareError = true;
      return 0.0; // Jika error bacaan diabaikan dan beri tau flag error
    } else {
      hardwareError = false;
    }

    readings[i] = sensor_height_frame - (dist / 10.0) + height_offset;
    delay(10); // Jeda tipis
  }

  // Mengurutkan dengan Bubble Sort
  for (int i = 0; i < 4; i++) {
    for (int j = i + 1; j < 5; j++) {
      if (readings[i] > readings[j]) {
        float temp = readings[i];
        readings[i] = readings[j];
        readings[j] = temp;
      }
    }
  }

  return readings[2];
}

// ==========================================
// SENSOR READING
// ==========================================
void readSensors() {
  // --- Baca Berat (Dengan Median + EMA Filter) ---
  if (loadCellReady) {
    if (scale.is_ready()) {
      float weight = getMedianWeight();
      if (weight < 0.05)
        weight = 0.0; // Filter noise kecil

      // Terapkan EMA Filter
      smoothedWeight =
          (alphaWeight * weight) + ((1.0 - alphaWeight) * smoothedWeight);
      currentWeight = smoothedWeight;
    } else {
      Serial.println("⚠️ HX711 tidak merespon (load cell lepas?)");
    }
  } else {
    currentWeight = 0.0;  // Load cell belum tersambung
    smoothedWeight = 0.0; // Reset filter
  }

  // --- Baca Tinggi (Dengan Median + EMA Filter) ---
  if (vl53l0xReady) {
    float height = getMedianHeight();
    if (height < 0.0) {
      height = 0.0;
    }

    // Hanya simpan jika hardwareError tidak trigger pada VL53L0X
    if (!hardwareError) {
      // Terapkan EMA Filter
      smoothedHeight =
          (alphaHeight * height) + ((1.0 - alphaHeight) * smoothedHeight);
      currentHeight = smoothedHeight;
    }
  } else {
    currentHeight = 0.0; // Sensor Lidar belum tersambung
    smoothedHeight = 0.0;
  }
}

// ==========================================
// NEOPIXEL DYNAMIC WAVE
// ==========================================
void updateNeoPixelWave(unsigned long currentTime) {
  // Warna kuning berkedip saat OTA berlangsung
  if (otaInProgress) {
    bool ledState = (currentTime / 150) % 2 == 0;
    pixels.setPixelColor(0, ledState ? pixels.Color(255, 165, 0)
                                     : pixels.Color(0, 0, 0));
    pixels.show();
    return;
  }

  if (hardwareError) {
    // Berkedip merah lambat (Peringatan santai 500ms on/off)
    bool ledState = (currentTime / 500) % 2 == 0;
    pixels.setPixelColor(0, ledState ? pixels.Color(255, 0, 0)
                                     : pixels.Color(0, 0, 0));
    pixels.show();
    return;
  }

  // Animasi nafas (breathing) berdenyut sangat pelan dan tenang (divisor 400.0)
  float wave = (sin(currentTime / 400.0) + 1.0) / 2.0; // nilai: 0.0 sampai 1.0
  int brightness = 5 + (int)(wave * 200.0); // Naik turun mulus (5 s/d 205)

  if (deviceConnected) {
    pixels.setPixelColor(0, pixels.Color(0, brightness, 0)); // Gelombang Hijau
  } else if (apActive) {
    pixels.setPixelColor(
        0, pixels.Color(brightness / 2, 0, brightness)); // Ungu saat AP aktif
  } else {
    pixels.setPixelColor(0, pixels.Color(0, 0, brightness)); // Gelombang Biru
  }
  pixels.show();
}

// ==========================================
// WIFI & OTA SETUP
// ==========================================
void setupWiFiAndOTA() {
  Serial.println("📶 Membuat Access Point WiFi...");
  Serial.print("   AP SSID    : ");
  Serial.println(AP_SSID);
  Serial.print("   AP Password: ");
  Serial.println(AP_PASSWORD);

  lcd.setCursor(0, 3);
  lcd.print("WiFi AP: Starting...");

  // Mode AP: ESP32 membuat hotspot sendiri
  WiFi.mode(WIFI_AP);

  // Set IP Address AP custom
  IPAddress apLocalIP(23, 23, 23, 1);
  IPAddress apGateway(23, 23, 23, 1);
  IPAddress apSubnet(255, 255, 255, 0);
  WiFi.softAPConfig(apLocalIP, apGateway, apSubnet);

  bool apStarted;
  if (strlen(AP_PASSWORD) >= 8) {
    apStarted = WiFi.softAP(AP_SSID, AP_PASSWORD);
  } else {
    apStarted = WiFi.softAP(AP_SSID); // Open AP jika password < 8 karakter
  }

  if (apStarted) {
    apActive = true;
    apIPAddress = WiFi.softAPIP().toString(); // Custom: 23.23.23.1
    Serial.print("✅ Access Point Aktif! IP: ");
    Serial.println(apIPAddress);

    // Tampilkan IP AP di LCD sebentar
    lcd.setCursor(0, 3);
    String ipShow = "AP:" + apIPAddress + "     ";
    lcd.print(ipShow.substring(0, 20));

    // ---- Setup ElegantOTA ----
    // Halaman root → informasi singkat esp32
    server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
      String html =
          "<html><body style='font-family:sans-serif;text-align:center;'>";
      html += "<h2>E-Posyandu ESP32</h2>";
      html += "<p>Berat : <b>" + String(currentWeight, 2) + " kg</b></p>";
      html += "<p>Tinggi: <b>" + String(currentHeight, 1) + " cm</b></p>";
      html += "<p><a href='/update'>OTA Firmware Update</a></p>";
      html += "</body></html>";
      request->send(200, "text/html", html);
    });

    // Aktifkan ElegantOTA dengan autentikasi username:password
    ElegantOTA.begin(&server, OTA_USERNAME, OTA_PASSWORD);

    // Callback saat OTA mulai
    ElegantOTA.onStart([]() {
      otaInProgress = true;
      otaStartTime = millis();
      Serial.println("\n🚀 OTA Update DIMULAI!");
      updateLCDOTA(0);
    });

    // Callback progress OTA
    ElegantOTA.onProgress([](size_t current, size_t total) {
      int pct = (int)((current * 100) / total);
      Serial.printf("   OTA Progress: %d%%\n", pct);
      updateLCDOTA(pct);
    });

    // Callback saat OTA selesai
    ElegantOTA.onEnd([](bool success) {
      if (success) {
        Serial.println("✅ OTA Update BERHASIL! Restarting...");
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("OTA BERHASIL!       ");
        lcd.setCursor(0, 1);
        lcd.print("Restarting ESP32... ");
        pixels.setPixelColor(0, pixels.Color(0, 255, 0)); // Hijau solid
        pixels.show();
      } else {
        Serial.println("❌ OTA Update GAGAL!");
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("OTA GAGAL!          ");
        lcd.setCursor(0, 1);
        lcd.print("Coba upload ulang.  ");
        pixels.setPixelColor(0, pixels.Color(255, 0, 0)); // Merah solid
        pixels.show();
      }
      otaInProgress = false;
      delay(2000);
    });

    server.begin();
    Serial.println("🌐 Web Server OTA aktif!");
    Serial.print("   Sambungkan HP/Laptop ke WiFi: ");
    Serial.println(AP_SSID);
    Serial.print("   Buka browser: http://");
    Serial.print(apIPAddress);
    Serial.println("/update");
    Serial.print("   Username: ");
    Serial.print(OTA_USERNAME);
    Serial.print(" | Password: ");
    Serial.println(OTA_PASSWORD);

  } else {
    apActive = false;
    Serial.println("⚠️ Gagal membuat Access Point! OTA tidak tersedia.");
    Serial.println("   → BLE & sensor tetap berfungsi normal.");
    lcd.setCursor(0, 3);
    lcd.print("AP: Gagal (OTA off) ");
    delay(1500);
  }
}

// ==========================================
// SETUP
// ==========================================
void setup() {
  Serial.begin(115200);
  Serial.println("\n====================================");
  Serial.println("  E-POSYANDU Real Sensors (BLE+OTA)");
  Serial.println("====================================");

  // Init LED RGB (Brightness & Color diatur otomatis oleh dynamic wave di loop)
  pixels.begin();
  pixels.setBrightness(255);

  // Init I2C untuk Sensor Tinggi & LCD pada Pin Khusus ESP32-C6
  Wire.begin(I2C_SDA, I2C_SCL);

  // ---- I2C Scanner ----
  Serial.println("🔍 Scanning I2C bus...");
  byte i2cDeviceCount = 0;
  bool lcdFound = false;
  bool vl53l0xFound = false;
  for (byte addr = 1; addr < 127; addr++) {
    Wire.beginTransmission(addr);
    byte error = Wire.endTransmission();
    if (error == 0) {
      Serial.print("   ✅ I2C device found at 0x");
      if (addr < 16)
        Serial.print("0");
      Serial.println(addr, HEX);
      i2cDeviceCount++;
      if (addr == LCD_I2C_ADDRESS)
        lcdFound = true;
      if (addr == VL53L0X_I2C_ADDRESS)
        vl53l0xFound = true;
    }
  }
  Serial.print("   Total I2C devices: ");
  Serial.println(i2cDeviceCount);
  if (!lcdFound)
    Serial.println("   ⚠️ LCD (0x27) TIDAK ditemukan!");
  if (!vl53l0xFound)
    Serial.println("   ⚠️ VL53L0X (0x29) TIDAK ditemukan!");
  Serial.println();

  // Init LCD
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print(" Inisialisasi...    ");

  // Init Load Cell HX711 (non-blocking, timeout 3 detik)
  Serial.println("⚖️ Initializing Load Cell HX711...");
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(calibration_factor);

  // Cek apakah load cell tersambung dengan timeout
  unsigned long hx711Timeout = millis();
  bool hx711Detected = false;
  while (millis() - hx711Timeout < 3000) { // Timeout 3 detik
    if (scale.is_ready()) {
      hx711Detected = true;
      break;
    }
    delay(100);
  }

  if (hx711Detected) {
    scale.tare(10); // Auto-zeroing
    zero_factor = scale.read_average(10);
    loadCellReady = true;
    Serial.println("   ✅ Load Cell Siap!");
  } else {
    loadCellReady = false;
    Serial.println("   ⚠️ Load Cell TIDAK tersambung! (HX711 timeout)");
    Serial.println("   → BLE tetap aktif, berat = 0.0 kg");
    lcd.setCursor(0, 1);
    lcd.print("LoadCell: N/A       ");
  }

  // Init VL53L0X dengan alamat eksplisit 0x29
  Serial.println("📏 Initializing VL53L0X at 0x29...");
  sensorHeight.setTimeout(500);
  sensorHeight.setAddress(VL53L0X_I2C_ADDRESS); // Set alamat eksplisit
  if (!sensorHeight.init()) {
    Serial.println("   ❌ Gagal mendeteksi VL53L0X di 0x29!");
    lcd.setCursor(0, 1);
    lcd.print("VL53L0X Error!      ");
    hardwareError = true;
    vl53l0xReady = false;
  } else {
    // Timing budget diatur ke 50ms (50.000 microsecond) untuk High-Speed
    // scanning! Meski lebih cepat, noise akan tetap aman karena diredam oleh
    // Median dan EMA kita.
    sensorHeight.setMeasurementTimingBudget(50000);
    sensorHeight.startContinuous(); // <-- Mengaktifkan Burst Mode
    Serial.println("   ✅ VL53L0X Siap di 0x29 (Burst Mode)!");
    vl53l0xReady = true;
  }

  // Init WiFi & ElegantOTA
  setupWiFiAndOTA();

  // Init BLE
  Serial.println("🔧 Initializing BLE...");
  NimBLEDevice::init(DEVICE_NAME);
  NimBLEDevice::setPower(ESP_PWR_LVL_P9); // Max power
  pServer = NimBLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  NimBLEService *pService = pServer->createService(SERVICE_UUID);
  pDataCharacteristic = pService->createCharacteristic(
      DATA_CHAR_UUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
  pCommandCharacteristic =
      pService->createCharacteristic(COMMAND_CHAR_UUID, NIMBLE_PROPERTY::WRITE);
  pCommandCharacteristic->setCallbacks(new CommandCallbacks());

  pService->start();

  NimBLEAdvertising *pAdvertising = NimBLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->enableScanResponse(true);
  NimBLEDevice::startAdvertising();

  // Ambil MAC Address ESP32
  bleMacAddress = NimBLEDevice::getAddress().toString().c_str();
  bleMacAddress.toUpperCase();
  Serial.print("✅ BLE Ready! MAC: ");
  Serial.println(bleMacAddress);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sistem Siap!        ");
  lcd.setCursor(0, 1);
  lcd.print("MAC:");
  lcd.setCursor(0, 2);
  lcd.print(bleMacAddress);
  if (apActive) {
    lcd.setCursor(0, 3);
    String ipShow = "OTA:" + apIPAddress;
    lcd.print(ipShow.substring(0, 20));
  }
  delay(2000);
  updateLCD("WAITING");
}

// ==========================================
// LOOP
// ==========================================
void loop() {
  unsigned long currentTime = millis();

  // Handle ElegantOTA (wajib dipanggil di loop agar OTA bisa berjalan)
  ElegantOTA.loop();

  // Jika OTA sedang berjalan, tunda logika sensor & BLE
  if (otaInProgress) {
    updateNeoPixelWave(currentTime);
    return; // Skip semua proses lain saat OTA
  }

  // Jalankan animasi wave / breathing pada NeoPixel
  updateNeoPixelWave(currentTime);

  // 1. Timer Membaca Sensor (Lebih cepat agar EMA responsif)
  if (currentTime - lastReadTime >= readInterval) {
    readSensors();
    lastReadTime = currentTime;
  }

  // 2. Timer Update Layar & Kirim BLE (Lebih lambat agar tidak spam)
  if (currentTime - lastSendTime >= sendInterval) {
    updateLCD(deviceConnected ? "Connected" : "WAITING");

    // Kirim data jika ada yang terhubung
    if (deviceConnected) {
      // Format: "berat,tinggi" -> contoh: "5.23,67.8"
      String data = String(currentWeight, 2) + "," + String(currentHeight, 1);
      pDataCharacteristic->setValue(data.c_str());
      pDataCharacteristic->notify();

      Serial.print("📤 Sent BLE: ");
      Serial.println(data);
    } else {
      Serial.print("📊 Data => Berat: ");
      Serial.print(currentWeight, 2);
      Serial.print(" kg, Tinggi: ");
      Serial.print(currentHeight, 1);
      Serial.println(" cm");

      // Tampilkan info OTA di Serial jika AP aktif
      if (apActive) {
        Serial.print("🌐 OTA URL: http://");
        Serial.print(apIPAddress);
        Serial.println("/update");
        Serial.print("   (Sambungkan ke WiFi: ");
        Serial.print(AP_SSID);
        Serial.println(")");
      }
    }

    lastSendTime = currentTime;
  }

  // Handle reconnect
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    NimBLEDevice::startAdvertising();
    oldDeviceConnected = deviceConnected;
  }
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  // Perintah serial "tare" dari laptop
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    if (command == "tare") {
      if (loadCellReady) {
        scale.tare(10);
        Serial.println("Scale tared from Serial");
      } else {
        Serial.println("Tare GAGAL: Load cell tidak tersambung");
      }
    }
  }

  delay(10);
}
