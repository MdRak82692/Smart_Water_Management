class WaterUsageData {
  double flowRate; // Variable to store flow rate of water
  double totalUsed; // Variable to store total water used
  double usedToday; // Variable to store water used today
  double waterLimit; // Variable to store water limit

  // Constructor to initialize all variables
  WaterUsageData({
    required this.flowRate,
    required this.totalUsed,
    required this.usedToday,
    required this.waterLimit,
  });

  // Factory constructor to create an initial instance with default values
  factory WaterUsageData.initial() {
    return WaterUsageData(
      flowRate: 0.0, // Default flow rate
      totalUsed: 0.0, // Default total used water
      usedToday: 0.0, // Default water used today
      waterLimit: 0.0, // Default water limit
    );
  }
}
