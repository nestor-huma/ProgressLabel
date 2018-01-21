//
//  UIImage+Gradient.swift
//  NPGradientImageExample
//
//  Created by Nestor Popko on 3/7/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//
import UIKit

extension UIImage {
    static func gradientImage(colors: [UIColor], locations: [CGFloat], size: CGSize, horizontal: Bool = false) -> UIImage {
        let endPoint = horizontal ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 0.0, y: 1.0)
        return gradientImage(colors: colors, locations: locations, startPoint: .zero, endPoint: endPoint, size: size)
    }
    
    static func gradientImage(colors: [UIColor], locations: [CGFloat], startPoint: CGPoint, endPoint: CGPoint, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!);
        
        let components = colors.reduce([]) { (currentResult: [CGFloat], currentColor: UIColor) -> [CGFloat] in
            var result = currentResult
            guard let components = currentColor.cgColor.components else {
                return result
            }
            if components.count == 2 {
                result.append(contentsOf: [components[0], components[0], components[0], components[1]])
            } else {
                result.append(contentsOf: [components[0], components[1], components[2], components[3]])
            }
            return result
        }
        
        let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: components, locations: locations, count: colors.count);
        
        let transformedStartPoint = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
        let transformedEndPoint = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)
        context!.drawLinearGradient(gradient!, start: transformedStartPoint, end: transformedEndPoint, options: []);
        UIGraphicsPopContext();
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return gradientImage!
    }
}

