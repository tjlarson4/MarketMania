//
//  SearchVC.swift
//  MarketMania
//
//  Created by Thor Larson on 3/16/21.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //
    // MARK: View Lifecycle
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hex: "272C37")
        
        self.navigationController?.navigationBar.barTintColor = .red

        
        collectionView1.delegate = self
        collectionView1.dataSource = self
        
        collectionView2.delegate = self
        collectionView2.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.delegate = self
        tableView.dataSource = self
        // self.tableView.register(UINib.init(nibName: "UITableViewCell", bundle: nil), forCellReuseIdentifier: "UITableViewCell")
        
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        getMostActive { response in
            // UI updates are only allowed in main queue
            DispatchQueue.main.async {
                //print("winners", response)
                self.popularStocks = response
                self.collectionView1.reloadData()
            }
        }
        
        // fill sector labels
        sectorLabels = getSectorLabels()
        
        setUpViews()
    }
    
    //
    // MARK: Functions
    //
    
    func getSectorLabels() -> [String] {
        let url = Bundle.main.url(forResource: "Stock_Sectors", withExtension: "json")
        
        guard let jsonData = url else {return ["Error retrieving JSON data"]}
        guard let data = try? Data(contentsOf: jsonData) else {return["Error transforming json"]}
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            else {return["Error serializing JSON object"]}
        
        var ret: [String] = []
        let sectors = json["sectors"] as? [[String: Any]]
        for sector in sectors as? [[String: String]] ?? [["name": "error"]]{
            if let name = sector["name"] {
                ret.append(name)
                //print(name)
            }
        }
        
        return ret
    }
    
    //
    // MARK: UI Setup
    //

    
    var dummyData = ["A", "AB", "ABC", "ABCD"]
    var activeSearch: Bool = false
    var filtered: [String] = []
    var popularStocks: [Stock] = []
    var sectorLabels: [String] = []
    
    
    var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.backgroundColor = .clear
        sb.searchBarStyle = UISearchBar.Style.prominent
        sb.placeholder = "Search..."
        
        //change color of "Search..."
        var searchTextField: UITextField? = sb.value(forKey: "searchField") as? UITextField
           if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.black]
               searchTextField!.attributedPlaceholder = NSAttributedString(string: "Search", attributes: attributeDict)
           }
        
        sb.sizeToFit()
        sb.isTranslucent = true
        return sb
    }()
    
    let tableView: UITableView = {
        let tb = UITableView()
        tb.backgroundColor = UIColor(hex: "272C37")
        return tb
        
    }()
    
    let exploreLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Explore", font: UIFont(boldWithSize: 25), textColor: .white)
        label.textAlignment = .center
        return label
        
    }()
    
    let mostPopularLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Most popular", font: UIFont(name: "PingFangHK-Medium", size: 15)!, textColor: .white)
        label.textAlignment = .center
        return label
    }()
    
    //most popular collection view
    let collectionView1: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        // register cells
        cv.register(mostPopularCell.self, forCellWithReuseIdentifier: "mostPopularCell")
        return cv
    }()
    
    let sectorsLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Sectors", font: UIFont(name: "PingFangHK-Medium", size: 15)!, textColor: .white)
        label.textAlignment = .center
        return label
    }()
    
    //sectors collection view
    let collectionView2: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //cv.backgroundColor = .menu_white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        // register cells
        cv.register(sectorCell.self, forCellWithReuseIdentifier: "sectorCell")
        return cv
    }()
    
    
    // search bar functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
        activeSearch = true
        
        tableView.isHidden = false
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: false)
        activeSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: false)
        activeSearch = false
        
        tableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: false)
        
        activeSearch = false
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty == false {
            filtered = dummyData.filter { name in return name.lowercased().contains(searchText.lowercased())}
        }
        else {
            filtered = dummyData
        }
        
//        filtered = dummyData.filter({ (text) -> Bool in
//            let tmp: NSString = text as NSString
//            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//            return range.location != NSNotFound
//        })
        
        if (filtered.count == 0) {
            if (searchText.isEmpty == true) {
                activeSearch = false
            }
            else {
                filtered = []
                activeSearch = true
            }
        } else {
            activeSearch = true
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (activeSearch) {
            return filtered.count
        } else {
            return dummyData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        if (activeSearch) {
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = dummyData[indexPath.row]
        }
        
        //make search table view cells black with white text
        cell.backgroundColor = UIColor(hex: "3A3E50")
        cell.textLabel?.textColor = .white
        cell.layer.borderColor = UIColor(hex: "686B75").cgColor
        cell.layer.borderWidth = 0.2
        
        return cell
    }
    
    
    
    func setUpViews() {
        
        view.addSubviews(views: [tableView, exploreLabel, mostPopularLabel, collectionView1, sectorsLabel, collectionView2])
        
        
        //search bar anchor before it became the navigation title view
//        searchBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: exploreLabel.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        exploreLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: mostPopularLabel.topAnchor, right: nil, topConstant: 20, leftConstant: 10, bottomConstant: 20, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        mostPopularLabel.anchor(exploreLabel.bottomAnchor, left: view.leftAnchor, bottom: collectionView1.topAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        collectionView1.heightAnchor.constraint(equalTo: collectionView1.widthAnchor, multiplier: 0.4).isActive = true

        collectionView1.anchor(mostPopularLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        sectorsLabel.anchor(collectionView1.bottomAnchor, left: view.leftAnchor, bottom: collectionView2.topAnchor, right: nil, topConstant: 20, leftConstant: 10, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        collectionView2.anchor(sectorsLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        tableView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        tableView.isHidden = true
        view.bringSubviewToFront(tableView)

    }
}

extension SearchVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionView1.self {
            return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2.5)
        }
        
        return CGSize(width: (collectionView.frame.width/3)-10, height: collectionView.frame.width/3)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == collectionView1.self && popularStocks.count != 0) {
            return popularStocks.count
        } else if (collectionView == collectionView2.self && sectorLabels.count != 0) {
            return sectorLabels.count
        } else {
            return 6
        }
        
        //return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == collectionView1.self && popularStocks.count != 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mostPopularCell", for: indexPath) as! mostPopularCell
            
            let stock = popularStocks[indexPath.row]
            
            cell.tickerLabel.text = stock.symbol
            cell.nameLabel.text = stock.companyName
            cell.moveLabel.text = String((stock.changePercent ?? 0.0)) + "%"

            
            return cell
        } else if (collectionView == collectionView2.self && sectorLabels.count != 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectorCell", for: indexPath) as! sectorCell
            cell.sectorLabel.text = sectorLabels[indexPath.row]
            return cell
        }
        
        //**** Commented out for now to see UI
//        let stock = winners[indexPath.row]
//
//        cell.tickerLabel.text = stock.symbol
//        cell.nameLabel.text = stock.companyName
//        cell.moveLabel.text = String((stock.changePercent ?? 0.0))
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectorCell", for: indexPath) as! sectorCell
        return cell
       
    }
    
    //allows each sector cell change view to it's category collection view (SectorCategoryVC)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView2.self {
            let controller = SectorCategoryVC()
            controller.selectedIndex = indexPath.row
            controller.selectedSector = sectorLabels[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class mostPopularCell: UICollectionViewCell {
    
    let tickerLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Placeholder", font: UIFont(boldWithSize: 18), textColor: .white)
        label.textAlignment = .left
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Subtext placeholder", font: UIFont(regularWithSize: 11), textColor: .white)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    let moveLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Move %", font: UIFont(boldWithSize: 26), textColor: .white)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(hex: "3A3E50")
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        
        setUpViews()
        
//        let stack: UIStackView = setUpViews()
//        self.contentView.addSubview(stack)
//
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            stack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            stack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            stack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
//        ])
//
//        self.contentView.layer.cornerRadius = 5
    }
    
    func setUpViews() {
        
        contentView.addSubviews(views: [tickerLabel, nameLabel, moveLabel])
        
        tickerLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        nameLabel.anchor(tickerLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        moveLabel.anchor(nil, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
        
//        let stack = UIStackView()
//
//        stack.axis = .vertical
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        stack.addArrangedSubview(tickerLabel)
//        stack.addArrangedSubview(nameLabel)
//        stack.addArrangedSubview(moveLabel)
//
//        return stack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class sectorCell: UICollectionViewCell {
    
    let sectorLabel: UILabel = {
        let label = UILabel()
        label.add(text: "Sector", font: UIFont(boldWithSize: 12), textColor: .white)
        label.textAlignment = .center
        label.numberOfLines = 5
        return label
    }()
    
    //add image
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
                
        backgroundColor = UIColor(hex: "3A3E50")
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        
        setUpViews()
        
    }
    
//    func setupStack() -> UIStackView {
//        let stack = UIStackView()
//        stack.axis = .vertical
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        stack.addArrangedSubview(sectorLabel)
//        // add img
//
//        return stack
//    }
    
    func setUpViews() {
//        let stack: UIStackView = setupStack()
//        self.contentView.addSubview(stack)
//
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            stack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            stack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            stack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
//        ])
//
//        self.contentView.layer.cornerRadius = 5
        
        contentView.addSubview(sectorLabel)
        sectorLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
}
