List<String> _buildSkuValues(List<List<String>> optionGroups) {
  if (optionGroups.isEmpty) {
    return ['Mặc định'];
  }

  List<String> results = [''];
  for (final group in optionGroups) {
    final nextResults = <String>[];
    for (final prefix in results) {
      for (final option in group) {
        nextResults.add(prefix.isEmpty ? option : '$prefix, $option');
      }
    }
    results = nextResults;
  }
  return results;
}
