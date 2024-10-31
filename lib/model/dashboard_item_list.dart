class DashboardItemlist {
  late int id;
  late String url;
  late String whichContent;
  late String whichAudio;

  DashboardItemlist({required this.id, required this.url, required this.whichContent, required this.whichAudio});

  DashboardItemlist.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    url = json['url'];
    whichAudio = json["audio"];
    whichContent = json['link'];
  }
}
