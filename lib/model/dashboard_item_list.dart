class DashboardItemlist {
  late int id;
  late String url;
  late String whichContent;

  DashboardItemlist(
      {required this.id, required this.url, required this.whichContent});

  DashboardItemlist.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    url = json['url'];
    whichContent = json['link'];
  }
}
