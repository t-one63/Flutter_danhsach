import 'dart:math';
import 'package:flutter/material.dart';

class SampleItem {
  String id;
  ValueNotifier<String> name;

  SampleItem({String? id, required String name})
      : id = id ?? generateUuid(),
        name = ValueNotifier(name);

  static String generateUuid() {
    return int.parse(
            '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(100000)}')
        .toRadixString(35)
        .substring(0, 9);
  }
}

class SampleItemViewModel extends ChangeNotifier {
  SampleItemViewModel._();
  factory SampleItemViewModel() => _instance;
  static final _instance = SampleItemViewModel._();

  final List<SampleItem> items = [];

  void addItem(String name) {
    items.add(SampleItem(name: name));
    notifyListeners();
  }

  void removeItem(String id) {
    items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateItem(String id, String newName) {
    try {
      final item = items.firstWhere((item) => item.id == id);
      item.name.value = newName;
    } catch (e) {
      debugPrint("Không tìm thấy mục với ID $id");
    }
  }

  // Thêm tính năng tìm kiếm
  List<SampleItem> searchItems(String keyword) {
    return items
        .where((item) =>
            item.name.value.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }
}

class SampleItemUpdate extends StatefulWidget {
  final String? initialName;

  const SampleItemUpdate({Key? key, this.initialName}) : super(key: key);

  @override
  State<SampleItemUpdate> createState() => _SampleItemUpdateState();
}

class _SampleItemUpdateState extends State<SampleItemUpdate> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController =
        TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialName != null ? 'Chỉnh sửa' : 'Thêm mới'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(textEditingController.text);
            },
            child: Text(widget.initialName != null ? 'Chỉnh sửa' : 'Thêm mới'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                labelText: 'Tên mục',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(textEditingController.text);
              },
              child: Text(widget.initialName != null ? 'Cập nhật' : 'Thêm mới'),
            ),
          ],
        ),
      ),
    );
  }
}

class SampleItemWidget extends StatelessWidget {
  final SampleItem item;
  final VoidCallback? onTap;

  const SampleItemWidget({Key? key, required this.item, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: item.name,
      builder: (context, name, child) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(name),
            subtitle: Text(item.id),
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/flutter_logo.png'),
            ),
            onTap: onTap,
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        );
      },
    );
  }
}

class SampleItemDetailsView extends StatefulWidget {
  final SampleItem item;

  const SampleItemDetailsView({Key? key, required this.item}) : super(key: key);

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  final viewModel = SampleItemViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết mục'),
        actions: [
          TextButton(
            onPressed: () {
              showModalBottomSheet<String?>(
                context: context,
                builder: (context) => SampleItemUpdate(
                  initialName: widget.item.name.value,
                ),
              ).then((value) {
                if (value != null) {
                  viewModel.updateItem(widget.item.id, value);
                }
              });
            },
            child: const Text('Cập nhật'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Xác nhận xóa"),
                    content: const Text("Bạn có chắc muốn xóa mục này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          viewModel.removeItem(widget.item.id);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Xóa"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên: ${widget.item.name.value}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'ID: ${widget.item.id}',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({Key? key}) : super(key: key);

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final viewModel = SampleItemViewModel();
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Mục'),
        actions: [
          TextButton(
            onPressed: () {
              showModalBottomSheet<String?>(
                context: context,
                builder: (context) => const SampleItemUpdate(),
              ).then((value) {
                if (value != null) {
                  viewModel.addItem(value);
                }
              });
            },
             child: const Text('Thêm mới'),
          ),
          TextButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SampleItemSearchDelegate(viewModel),
              );
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
        
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView.builder(
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              return SampleItemWidget(
                item: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SampleItemDetailsView(item: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SampleItemSearchDelegate extends SearchDelegate<String> {
  final SampleItemViewModel viewModel;

  SampleItemSearchDelegate(this.viewModel);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = viewModel.searchItems(query);
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        return ListTile(
          title: Text(item.name.value),
          subtitle: Text(item.id),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SampleItemDetailsView(item: item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchResults = viewModel.searchItems(query);
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        return ListTile(
          title: Text(item.name.value),
          subtitle: Text(item.id),
          onTap: () {
            query = item.name.value;
            showResults(context);
          },
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SampleItemListView(),
    );
  }
}

