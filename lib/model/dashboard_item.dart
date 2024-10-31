class DashboardItem {
  late int id;
  late String url;
  late String audio;

  DashboardItem({required this.id, required this.url, required this.audio});

  DashboardItem.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    url = json['url'];
    audio = json["audio"];
  }
}