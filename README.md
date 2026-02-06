# PowerTracker
SmartEnergy Monitoring application/IoT

## Description
- PowerTracker is a smart and easy-to-use app designed to help users monitor their current kilowatt (kW) consumption in real time. It provides clear insights into power usage, helping users understand, manage, and optimize their electricity consumption efficiently.

## Technologies Used
- ESP8266 Microcontroller
- Arduino C/C++
- Flutter/Dart
- MQTT Protocol
- Firebase Cloud Platform
- IoT Sensors (ZMPT101B, DHT22)
- Real-time Database

## Features

### User Functions
- View real-time electricity usage
- Monitor appliance-level energy consumption
- View estimated electricity cost
- Access usage history and consumption charts

### Monitoring and Management Functions
- Continuous monitoring of electrical current and power
- Aggregation of energy data into kilowatt-hours (kWh)
- Identification of high energy consumption periods
- Detection of abnormal or sudden power usage

### Control Functions
- Remote ON/OFF control of connected appliances
- Manual override through the application
- Scheduling of appliance operation to reduce energy waste

### Notification Functions
- Alerts for high power usage
- Notifications for appliances left ON
- Warnings for abnormal or irregular electricity consumption

### Cloud and IoT Functions
- Real-time data transmission from Arduino/ESP32 to the cloud
- Secure cloud storage of historical energy usage
- Synchronization between IoT device, cloud services, and mobile application
- Remote access to energy data anytime and anywhere

## Installation Instructions
- Clone the repository: git clone <repo-url> and navigate to the project folder
- Install dependencies: flutter pub get
- Add Firebase configuration files (google-services.json for Android, GoogleService-Info.plist for iOS) to their respective folders
- Update lib/config.dart with your WiFi name, MQTT broker address, username, and password
- Run the app: flutter run

## Setup
### Hardware Setup:

- Connect relay module to ESP8266 pin D1, DHT22 to D5, ZMPT101B to A0, and HLK-PM01 power supply to AC input
- Wire the relay to control the AC socket output (get help from an adult for AC wiring)
- Install ESP8266 board support and required libraries (PubSubClient, DHT, ArduinoJson) in Arduino IDE
- Update WiFi and MQTT credentials in firmware/smart_plug.ino
- Upload the code to ESP8266 via USB

### Cloud Setup:

- Create Firebase project, enable Authentication and Realtime Database, download config files
- Create HiveMQ Cloud account, create free cluster, and note broker URL, port, username, and password
- Update MQTT credentials in both firmware/smart_plug.ino and lib/config.dart
- Power on the smart plug and verify connection via Serial Monitor (should show "WiFi Connected" and "MQTT Connected")
- Open app, create account, add device, and test ON/OFF control
