import UIKit

class AddPlaceListSection: UITableViewCell {

    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(hideList), name: NSNotification.Name(rawValue: "hidePlaceList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showList), name: NSNotification.Name(rawValue: "showPlaceList"), object: nil)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func hideList() {
        title.isHidden = true
    }
    
    @objc private func showList() {
        title.isHidden = false
    }
}
