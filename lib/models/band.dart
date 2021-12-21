

class Band {

  String id;
  String name;
  int votes;

  Band({
    this.id = '',//deben inicializarse ya que dart ya no admite valores null
    this.name = '',
    this.votes = 0,
  });

  factory Band.fromMap( Map<String, dynamic> obj )
  => Band(
    id: obj['id'],
    name: obj['name'],
    votes: obj['votess']
    );

}