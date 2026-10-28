class BannerItem {
  final String title;
  final String bannerUrl;

  BannerItem({required this.title, required this.bannerUrl});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      title: json['title']?.toString() ?? '',
      bannerUrl: json['bannerUrl']?.toString() ?? '',
    );
  }

  Map<String, String> toJson() {
    return {'title': title, 'bannerUrl': bannerUrl};
  }
}
