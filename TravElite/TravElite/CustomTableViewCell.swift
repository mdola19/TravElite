//
//  CustomTableViewCell.swift
//  TravElite
//
//  Created by Manjot Dola on 2022-07-25.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 10, y: 8, width: self.frame.width + 50, height: 110))
        view.backgroundColor = UIColor.cyan.withAlphaComponent(0.35)
        
        return view
    }()
    
    lazy var destinationlbl: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 0, y: backView.frame.height/2 - 30, width: backView.frame.width, height: 30))
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "Poppins-Semibold", size: 24)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    lazy var startLocLbl: UILabel = {
        let newlbl = UILabel(frame: CGRect(x: 0, y: backView.frame.height/2 + 10, width: backView.frame.width, height: 30))
        newlbl.textAlignment = .center
        newlbl.font = UIFont(name: "Poppins-Regular", size: 16)
        newlbl.textColor = UIColor.black
        return newlbl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        backView.layer.cornerRadius = 15
        backView.clipsToBounds = true
        backView.addSubview(destinationlbl)
        backView.addSubview(startLocLbl)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(backView)
        // Configure the view for the selected state
    }
    
    

}
