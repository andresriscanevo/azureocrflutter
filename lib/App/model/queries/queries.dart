class QueriesAzureOCR {
  static const String insertData = r"""
mutation InsertAzureVision($image: String, $name: String) {
  insert_Azure_Vision(objects: {image: $image, name: $name}) {
    affected_rows
    returning {
      id
			image
			name
			create_date_time
    }
  }
}
""";
}
