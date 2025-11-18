enum OperationTypeEnum {
  addOrUpdate,
  delete;

  static OperationTypeEnum fromString(String value){
    switch(value){
      case "OperationTypeEnum.addOrUpdate":
        return OperationTypeEnum.addOrUpdate;
      case "OperationTypeEnum.delete":
        return OperationTypeEnum.delete;
      default:
        throw Exception("Invalid operation type");

    }
  }
}