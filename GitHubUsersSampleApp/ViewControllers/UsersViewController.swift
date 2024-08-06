//
//  UsersViewController.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 06/03/2021.
//

import UIKit

class UsersViewController: UIViewController {

    //MARK: Internal Properties
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var stackView: UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        return stackView
    }
    
//    var filterButton: UIButton {
//        let button = UIButton(frame: .zero)
//        button.setTitle("Filter By Name", for: .normal)
//        button.backgroundColor = .red
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
//        return button
//    }
    
    let viewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        prepareUI()
        setData()
        fetchUserList()
    }
    
    func setData() {
        self.navigationItem.title = "Users"
    }
    
}

//MARK: Prepare UI

extension UsersViewController {
    
    func prepareUI() {
        prepareButton()
        prepareTableView()
        prepareStackView()
        prepareViewModelObserver()
    }
    
    func prepareStackView() {
        let stackView = UIStackView(arrangedSubviews: [tableView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    func prepareTableView() {
        self.view.backgroundColor = .white
        self.tableView.separatorStyle   = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")

    }
    
    func prepareButton() {

    }
}

//MARK: Private Methods

extension UsersViewController {
    
    func fetchUserList() {
        viewModel.fetchUserList(nextBatch: false)
    }
    
    
    func prepareViewModelObserver() {
        self.viewModel.userDidChanges = { (finished, error) in
            if !error {
                self.reloadTableView()
            }
        }
        
        self.viewModel.userFetched = {(user) in
            if let vc = self.storyboard?.instantiateViewController(identifier: "UserDetailViewController") as? UserDetailViewController {
                vc.userDetail = user
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
}

// MARK: - UITableView Delegate And Datasource Methods

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getUsers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath as IndexPath) as? UserTableViewCell else {
            fatalError("AddressCell cell is not found")
        }
        
        let user = viewModel.getUsers()[indexPath.row]
       cell.userItem = user
        
        if indexPath.row == viewModel.getUsers().count - 1 {
            self.viewModel.fetchUserList(nextBatch: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableView.automaticDimension
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = viewModel.getUsers()[indexPath.row]
        self.viewModel.fetchUserDetail(userName: user.login!)
    }
}



