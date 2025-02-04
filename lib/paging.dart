// class Paging<T> {
//   List<T>? data;
//   int? pageNo;
//   int? pageSize;
//   int? totalPages;
//   int? totalRecords;
//
//   Paging({
//     this.data,
//     this.pageNo,
//     this.pageSize,
//     this.totalPages,
//     this.totalRecords,
//   });
//
//   @override
//   String toString() {
//     return 'Paging{data: $data, pageNo: $pageNo, pageSize: $pageSize, totalPage: $totalPages, totalRecords: $totalRecords}';
//   }
//
//   factory Paging.fromMap(Map<String, dynamic> data, {required Type type}) {
//     return Paging(
//       data: (data['data'] as List<dynamic>)
//           .map<T>((e) => factoryDataList(type, e))
//           .toList(),
//       pageNo: data['pageNo'] as int?,
//       pageSize: data['pageSize'] as int?,
//       totalPages: data['totalPages'] as int?,
//       totalRecords: data['totalRecords'] as int?,
//     );
//   }
//
//   static final _dataFactory = <Type, dynamic Function(Map<String, dynamic>)>{
//     CategoryResponse: CategoryResponse.fromJson,
//   };
//
//   static factoryDataList(Type type, data) {
//     if (data is String || data is num || data is bool) {
//       return data;
//     }
//     return _dataFactory[type]?.call(data);
//   }
// }
