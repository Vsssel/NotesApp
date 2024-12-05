//
//  NoteCell.swift
//  NotesApp
//
//  Created by Assel Artykbay on 05.12.2024.
//

import Foundation
import UIKit
import SnapKit

class NoteCell: UITableViewCell {
    static let identifier = "NoteCell"

    private let titleLabel = UILabel()
    private let contentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)

        contentLabel.numberOfLines = 1
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(contentLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(10)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(contentView).inset(10)
            make.bottom.equalTo(contentView).inset(10)
        }
    }

    func configure(with title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
}
