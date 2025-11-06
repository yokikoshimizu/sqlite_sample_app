import 'package:flutter/material.dart';
import 'package:sqlite_sample_app/DatabaseHelper.dart';
import 'package:sqlite_sample_app/dog_model.dart';

void main() {
  // アプリケーションの開始前にデータベースの初期化を待つ必要があれば、
  // ここで WidgetsFlutterBinding.ensureInitialized(); と await を使用します。
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite CRUD Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DogListScreen(),
    );
  }
}

// データの表示と操作を行うメイン画面
class DogListScreen extends StatefulWidget {
  const DogListScreen({super.key});

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  // データベースから取得した犬のリスト
  late Future<List<Dog>> _dogsFuture;

  // 初期化時にDBからデータを取得する
  @override
  void initState() {
    super.initState();
    _refreshDogList();
  }

  // データを再取得して画面を更新するメソッド
  void _refreshDogList() {
    setState(() {
      _dogsFuture = DatabaseHelper.instance.readAllDogs();
    });
  }

  // フォームを開いて犬の情報を追加/編集する
  void _showForm(Dog? dog) async {
    final TextEditingController nameController = TextEditingController(text: dog?.name);
    final TextEditingController ageController = TextEditingController(text:
    dog?.age.toString());

    // ダイアログで入力フォームを表示
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dog == null ? '犬を追加' : '犬を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '名前'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: '年齢'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final age = int.tryParse(ageController.text) ?? 0;

                if (name.isNotEmpty && age > 0) {
                  final newDog = Dog(
                    id: dog?.id,
                    name: name,
                    age: age,
                  );

                  if (dog == null) {
                    // C: Create (新規追加)
                    await DatabaseHelper.instance.create(newDog);
                  } else {
                    // U: Update (更新)
                    await DatabaseHelper.instance.update(newDog);
                  }

                  // データベース操作後、リストを更新
                  _refreshDogList();
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: Text(dog == null ? '追加' : '更新'),
            ),
          ],
        );
      },
    );
  }

  // D: Delete (削除)
  void _deleteDog(int id) async {
    await DatabaseHelper.instance.delete(id);
    // 削除後、リストを更新
    _refreshDogList();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('犬の情報を削除しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('犬のリスト（SQLite CRUD）'),
      ),
      body: FutureBuilder<List<Dog>>(
        // R: Read (データの読み込み)
        future: _dogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //ここのエラーは何？？
            return const Center(child: Text('データがありません。右下のボタンから追加してくだ
            さい。'));
          } else {
            // データがある場合、リスト表示
            final dogs = snapshot.data!;
            return ListView.builder(
            itemCount: dogs.length,
            itemBuilder: (context, index) {
            final dog = dogs[index];
            return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
            title: Text(dog.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('年齢: ${dog.age}歳'),
            trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            // U: Update (編集ボタン)
            IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showForm(dog), // 編集フォーム表示
            ),
            // D: Delete (削除ボタン)
            IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteDog(dog.id!), // 削除処理実行
            ),
            ],
            ),
            ),
            );
            },
            );
            }
            },
      ),
      // C: Create (追加ボタン)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null), // 新規追加フォーム表示
        tooltip: '犬を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
