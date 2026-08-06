/// A restaurant department (e.g. Kitchen, Bar, Front Desk) used to group
/// sub-menus and assign printers, managed from Manage > Setting > Department.
class Department {
  final String name;
  final String description;

  const Department({required this.name, this.description = ''});
}
