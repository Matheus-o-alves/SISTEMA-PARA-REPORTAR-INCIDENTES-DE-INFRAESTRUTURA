class UserEntity {
  final String uid;
  final String nome;
  final String cpf;
  final String email;

  const UserEntity({
    required this.uid,
    required this.nome,
    required this.cpf,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, nome, cpf, email];
}
