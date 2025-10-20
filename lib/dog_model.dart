class Dog {
  final int? id;
  final String name;
  final int age;

  //{} は 名前付き引数
  //this.id は 省略代入:引数 id をそのままフィールドにセット
  //required は 必須引数指定:name と age は必ず渡す必要があり
  //※省略代入と必須引数指定については復習の必要あり
  Dog({this.id, required this.name, required this.age});

  //Map へ変換。SQLiteに渡すとき、sqflite は Map<String, dynamic> 形式を使うため、この変換が必要
  //キー名（'id', 'name', 'age'）はテーブルのカラム名と一致させる
  //dynamic は値の型が可変（int や String など）するもので、sqflite が理解できるようにするためのものらしい
  //↑元々はDartオブジェクト？といったとらえ方らしい
  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name':name,
      'age':age,
    };
  }

  //※ファクトリコンストラクタについて要質問
  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id:map['id'],
      name:map['name'],
      age:map['age'],
    );
  }
}