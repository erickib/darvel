// @Entity(tableName: 'users')
// class User {
//   @PrimaryKey()
//   int? id;

//   @Column(type: 'VARCHAR', length: 255)
//   String name;

//   @Column(type: 'VARCHAR', length: 255, nullable: true)
//   String? email;

//   @Column(type: 'TIMESTAMP', defaultValue: 'CURRENT_TIMESTAMP')
//   DateTime createdAt;

//   User({
//     this.id,
//     required this.name,
//     this.email,
//     DateTime? createdAt,
//   }) : createdAt = createdAt ?? DateTime.now();
// }

// @Table(name: 'users')
// class User {
//   @Column(name: 'id', primaryKey: true)
//   final int id;

//   @Column(name: 'name')
//   final String name;

//   @OneToMany(relatedType: Post)
//   final List<Post> posts;

//   User({
//     required this.id,
//     required this.name,
//     required this.posts,
//   });
// }
