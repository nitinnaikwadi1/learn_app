class DashboardItem {
  late int id;
  late String url;
  late String audio;
  late String name;
  DashboardItem({required this.id, required this.url, required this.audio, required this.name});

  DashboardItem.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    url = json["url"];
    audio = json["audio"];
    name = json["name"];
  }
}