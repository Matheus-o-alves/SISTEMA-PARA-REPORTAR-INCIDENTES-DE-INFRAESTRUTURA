class UserModel {
  final String uid;
  final String nome;
  final String cpf;
  final String email;

  UserModel({
    required this.uid,
    required this.nome,
    required this.cpf,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpf': cpf,
      'email': email,
    };
  }
}
