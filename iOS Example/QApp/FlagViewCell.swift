//
//  FlagViewCell.swift
//  QApp
//
//  Created by Adel Ferguen on 19/09/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit

class FlagViewCell: UITableViewCell {
    @IBOutlet var typePicker: UIPickerView?

    @IBOutlet var campName: UITextField?
    @IBOutlet var campId: UITextField?
 
    @IBOutlet var varGName: UITextField?
    @IBOutlet var varGId: UITextField?
    
    @IBOutlet var varName: UITextField?
    @IBOutlet var varId: UITextField?
    
    @IBOutlet var isReferenceSwitch: UISwitch?
    @IBOutlet var flagValue: UITextField?
    
    @IBOutlet var typeCampaign: UITextField?
    @IBOutlet var slug: UITextField?
    
    @IBOutlet var statusFlag: UITextField?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ flag: FSFlag?) {
        if let aFlag = flag {
            let metedata = aFlag.metadata()
            campName?.text = metedata.campaignName
            campId?.text = metedata.campaignId
            varGName?.text = metedata.variationGroupName
            varGId?.text = metedata.variationGroupId
            varName?.text = metedata.variationName
            varId?.text = metedata.variationId
            flagValue?.text = String(format: "\(aFlag.value(visitorExposed: false) ?? "None")")
            isReferenceSwitch?.isOn = metedata.isReference
            slug?.text = metedata.slug
            typeCampaign?.text = metedata.campaignType
            statusFlag?.text = flag?.status.rawValue
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100 {
            let currentText = textField.text ?? ""

            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }

            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        } else if typePicker?.selectedRow(inComponent: 0) == 2 || typePicker?.selectedRow(inComponent: 0) == 1 {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        }
        return true
    }
    
    private func getTypeValue() -> FSValueType {
        switch typePicker?.selectedRow(inComponent: 0) {
        case 0:
            return .StringType
        case 1:
            return .IntegerType
        case 2:
            return .DoubleType
        case 3:
            return .BooleanType
            
        default:
            return .StringType
        }
    }
}
