import 'dart:convert';

ContentPageResponse contentPageResponseFromJson(String str) =>
    ContentPageResponse.fromJson(json.decode(str));

class ContentPageResponse {
  final List<ContentPage> data;
  final String message;
  final int status;

  ContentPageResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ContentPageResponse.fromJson(Map<String, dynamic> json) =>
      ContentPageResponse(
        data: List<ContentPage>.from(
            json["data"].map((x) => ContentPage.fromJson(x))),
        message: json["message"] ?? "",
        status: json["status"] ?? 500,
      );
}

class ContentPage {
  final int id;
  final String pageName;
  final String pageDetails;
  final String pageType;

  ContentPage({
    required this.id,
    required this.pageName,
    required this.pageDetails,
    required this.pageType,
  });

  factory ContentPage.fromJson(Map<String, dynamic> json) => ContentPage(
        id: json["id"],
        pageName: json["page_name"] ?? "Untitled",
        pageDetails: json["page_details"] ?? "<p>No content available.</p>",
        pageType: json["page_type"] ?? "",
      );
}
