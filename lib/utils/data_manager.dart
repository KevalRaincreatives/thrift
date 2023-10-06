
class DataManager {
  bool _connection = false;
  var _isSelected,_isShoesSelected,_isRequired;

  static final DataManager ourInstance = DataManager();
  static DataManager getInstance() {return ourInstance;}

  bool getConnection() {
    return _connection;
  }
  setConnection(value) {
    _connection = value;
  }

  String getIsSelected() {
    return _isSelected;
  }
  setIsSelected(value) {
    _isSelected = value;
  }

  String getIsShoesSelected() {
    return _isShoesSelected;
  }
  setIsShoesSelected(value) {
    _isShoesSelected = value;
  }

  String getIsRequired() {
    return _isRequired;
  }
  setIsRequired(value) {
    _isRequired = value;
  }

}