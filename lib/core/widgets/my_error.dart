class MyError{
  String errorMessage;
  String location;
  MyError({required this.errorMessage, required this.location});

  @override
    String toString() {
      return "MyError $errorMessage\t$location";
    }
}
