//
//  ViewController.swift
//  NotesApp
//
//  Created by Assel Artykbay on 05.12.2024.
//

import Foundation
import UIKit
import SnapKit

class NotesListController: UIViewController {
    private let table = UITableView()
    private let viewModel = NotesViewModel()
    var categorizedNotes = [String: [Note]]()
    var filteredNotes = [Note]()
    var isSearchActive = false

    
    lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addButtonTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        fetchNotes()
        setupSearchController()
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupUI() {
        navigationItem.title = "Notes"
        navigationItem.setRightBarButton(addButton, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground

        view.addSubview(table)
        table.register(NoteCell.self, forCellReuseIdentifier: NoteCell.identifier)
        table.dataSource = self
        table.delegate = self
        table.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func setupBindings() {
        viewModel.notesUpdated = { [weak self] in
            self?.categorizedNotes = self?.viewModel.categorizeNotesByDate(notes: self?.viewModel.notes ?? []) ?? [:]
            self?.table.reloadData()
        }
    }
    
    func fetchNotes() {
        do {
            viewModel.fetchNotes()
        } catch {
            print("Error fetching notes: \(error)")
        }
    }

    @objc private func addButtonTapped() {
        let addNoteVC = SingleNoteViewController()
        addNoteVC.delegate = self
        navigationController?.pushViewController(addNoteVC, animated: true)
    }
}

extension NotesListController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categorizedNotes.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = Array(categorizedNotes.keys)[section]
        return (isSearchActive ? filteredNotes : categorizedNotes[sectionTitle])?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(categorizedNotes.keys)[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else {
            return UITableViewCell()
        }

        let sectionTitle = Array(categorizedNotes.keys)[indexPath.section]
        let note = (isSearchActive ? filteredNotes : categorizedNotes[sectionTitle])?[indexPath.row]

        cell.configure(with: note?.title ?? "", content: note?.content ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedNote = categorizedNotes[Array(categorizedNotes.keys)[indexPath.section]]?[indexPath.row]
        
        let noteVC = SingleNoteViewController(note: selectedNote)
        noteVC.delegate = self
        navigationController?.pushViewController(noteVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sectionTitle = Array(categorizedNotes.keys)[indexPath.section]
            if let note = categorizedNotes[sectionTitle]?[indexPath.row] {
                viewModel.deleteNote(note)
                DispatchQueue.main.async {
                    self.fetchNotes()
                }
            }
        }
    }


}

extension NotesListController: SingleNoteDelegate {
    func didAddNote() {
        fetchNotes()
    }
}

extension NotesListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(), !query.isEmpty else {
            isSearchActive = false
            filteredNotes = viewModel.notes ?? []
            table.reloadData()
            return
        }
        
        isSearchActive = true
        filteredNotes = (viewModel.notes ?? []).filter { note in
            note.title?.lowercased().contains(query) == true || note.content?.lowercased().contains(query) == true
        }
        table.reloadData()
    }
}

