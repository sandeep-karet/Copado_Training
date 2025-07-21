public class SFMC_logoModel {
  public class body {
    public String Name;
    public String file;
    public assetType assetType;
    public category category;
    public FileProperties FileProperties;

    public body(
      String Name,
      String assetName,
      Integer assetId,
      String cateName,
      Integer cateId,
      String fileName,
      String file
    ) {
      this.Name = Name;
      this.assetType = new assetType(assetName, assetId);
      this.category = new category(cateName, cateId);
      this.FileProperties = new FileProperties(fileName);
      this.file = file;
    }
  }

  public class assetType {
    public String name;
    public Integer id;

    public assetType(String name, Integer id) {
      this.name = name;
      this.id = id;
    }
  }

  public class category {
    public String name;
    public Integer id;

    public category(String name, Integer id) {
      this.name = name;
      this.id = id;
    }
  }

  public class FileProperties {
    public String filename;

    public FileProperties(String filename) {
      this.filename = filename;
    }
  }
}