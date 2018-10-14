//
//  SearchImageViewController.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import UIKit

class SearchImageViewController: UICollectionViewController, ImageObserver, UISearchBarDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Photos, peoples or groups"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: MosaicLayout())
        collectionView.backgroundColor = .black
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageTileViewCell.self, forCellWithReuseIdentifier: ImageTileViewCell.identifer)
        
        ImageController.shared.fetchImages(searchTerm: "dogs", page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ImageController.AddObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ImageController.RemoveObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Data Source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageController.shared.imageCount()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageTileViewCell.identifer, for: indexPath) as? ImageTileViewCell
            else { preconditionFailure("Failed to load collection view cell") }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imageCell = cell as? ImageTileViewCell {
            ImageController.shared.getImageByIndex(indexPath.row) { (image) in
                if let imageByIndex = image {
                    imageCell.image = imageByIndex
                }
            }
        }
    }
    
    // MARK: - UICollectionView Delegate

    // MARK: - UISearchResultsUpdating Delegate
    // TODO: consider a type ahead search
    // func updateSearchResults(for searchController: UISearchController) {}
    
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        ImageController.shared.fetchImages(searchTerm: searchText, page: 1)
    }
    
    // MARK: - ImageObserver
    func newImagesLoaded() {
        DispatchQueue.main.async {
            self.collectionView.reloadData() // TODO: optimize reload to only reload what's changed
        }
    }
}

