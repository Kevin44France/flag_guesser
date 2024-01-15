class Score{
  final int score;
  final int gameType;

  const Score(this.score, this.gameType);

  factory Score.fromJson(Map<String, dynamic> json){
    return Score(
      json['score'],
      json['gameType']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'score': score,
      'gameType': gameType
    };
  }
}