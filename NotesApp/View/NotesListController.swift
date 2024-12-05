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
    
    lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addButtonTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        fetchNotes()
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
        return categorizedNotes[sectionTitle]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(categorizedNotes.keys)[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else {
            return UITableViewCell()
        }

        let sectionTitle = Array(categorizedNotes.keys)[indexPath.section]
        let note = categorizedNotes[sectionTitle]?[indexPath.row]

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


}

extension NotesListController: SingleNoteDelegate {
    func didAddNote() {
        fetchNotes()
    }
}
