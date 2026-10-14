import UIKit
import XCTest
@testable import SkeletonView

@MainActor
final class SkeletonRegressionTests: XCTestCase
{
    private func show(_ view: UIView)
    {
        view.isSkeletonable = true
        view.showSkeleton(transition: .none)
    }

    private func hide(_ view: UIView)
    {
        view.hideSkeleton(reloadDataAfter: false, transition: .none)
    }

    func testLabelUsesLatestTextAcrossLoadingCycles()
    {
        let label = UILabel()
        label.text = "Old"
        label.textColor = .red
        self.show(label)
        label.text = "New"
        XCTAssertEqual(label.textColor, .clear)
        self.hide(label)
        XCTAssertEqual(label.text, "New")
        XCTAssertEqual(label.textColor, .red)
        self.show(label)
        self.hide(label)
        XCTAssertEqual(label.text, "New")
    }

    func testLabelAcceptsNilAndEmptyTextWhileLoading()
    {
        let label = UILabel()
        for replacement: String? in [nil, ""]
        {
            label.text = "Old"
            self.show(label)
            label.text = replacement
            self.hide(label)
            XCTAssertEqual(label.text, replacement)
        }
    }

    func testAttributedTextRetainsLatestAttributes()
    {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Old", attributes: [.foregroundColor: UIColor.red])
        let replacement = NSAttributedString(string: "New", attributes: [
            .foregroundColor: UIColor.blue,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ])
        self.show(label)
        label.attributedText = replacement
        XCTAssertEqual(label.textColor, .clear)
        self.hide(label)
        XCTAssertEqual(label.attributedText, replacement)
    }

    func testTextColorUpdateIsPreservedAndHiddenDuringLoading()
    {
        let label = UILabel()
        label.text = "Old"
        self.show(label)
        label.textColor = .blue
        label.text = "New"
        XCTAssertEqual(label.textColor, .clear)
        self.hide(label)
        XCTAssertEqual(label.textColor, .blue)
        XCTAssertEqual(label.text, "New")
    }

    func testChangingAttributedTextColorMatchesUIKit()
    {
        let original = NSAttributedString(string: "Text", attributes: [
            .foregroundColor: UIColor.red,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ])
        let expected = UILabel()
        expected.attributedText = original
        expected.textColor = .blue
        let label = UILabel()
        label.attributedText = original
        self.show(label)
        label.textColor = .blue
        self.hide(label)
        XCTAssertEqual(label.attributedText, expected.attributedText)
        XCTAssertEqual(label.textColor, expected.textColor)
    }

    func testTextViewPreservesPlainAndAttributedUpdates()
    {
        let view = UITextView()
        view.text = "Old"
        self.show(view)
        view.text = "New"
        self.hide(view)
        XCTAssertEqual(view.text, "New")
        let text = NSAttributedString(string: "Attributed", attributes: [.foregroundColor: UIColor.green])
        self.show(view)
        view.attributedText = text
        self.hide(view)
        XCTAssertEqual(view.attributedText, text)
    }

    func testTextFieldPreservesTextAndPlaceholderUpdates()
    {
        let field = UITextField()
        field.text = "Old"
        field.placeholder = "Old placeholder"
        self.show(field)
        field.text = "New"
        field.placeholder = "New placeholder"
        XCTAssertNil(field.placeholder)
        self.hide(field)
        XCTAssertEqual(field.text, "New")
        XCTAssertEqual(field.placeholder, "New placeholder")
        self.show(field)
        field.text = nil
        field.placeholder = nil
        self.hide(field)
        XCTAssertTrue(field.text?.isEmpty ?? true)
        XCTAssertNil(field.placeholder)
    }

    func testAttributedPlaceholderIsRestored()
    {
        let field = UITextField()
        let placeholder = NSAttributedString(string: "New", attributes: [.foregroundColor: UIColor.red])
        self.show(field)
        field.attributedPlaceholder = placeholder
        XCTAssertNil(field.attributedPlaceholder)
        self.hide(field)
        XCTAssertEqual(field.attributedPlaceholder, placeholder)
    }

    func testImageUpdatesIncludingNilArePreserved()
    {
        let view = UIImageView()
        let image = UIImage(systemName: "star")!
        view.image = UIImage(systemName: "heart")
        self.show(view)
        view.image = image
        XCTAssertNil(view.image)
        self.hide(view)
        XCTAssertTrue(view.image === image)
        self.show(view)
        view.image = nil
        self.hide(view)
        XCTAssertNil(view.image)
    }

    func testButtonTitleUpdatesIncludingNilArePreserved()
    {
        let button = UIButton()
        button.setTitle("Old", for: .normal)
        self.show(button)
        button.setTitle("New", for: .normal)
        XCTAssertNil(button.title(for: .normal))
        self.hide(button)
        XCTAssertEqual(button.title(for: .normal), "New")
        self.show(button)
        button.setTitle(nil, for: .normal)
        self.hide(button)
        XCTAssertNil(button.title(for: .normal))
    }

    func testBackgroundUpdateIncludingClearIsPreserved()
    {
        let view = UIView()
        view.backgroundColor = .red
        self.show(view)
        view.backgroundColor = .blue
        XCTAssertEqual(view.backgroundColor, .clear)
        self.hide(view)
        XCTAssertEqual(view.backgroundColor, .blue)
        self.show(view)
        view.backgroundColor = .clear
        self.hide(view)
        XCTAssertEqual(view.backgroundColor, .clear)
    }

    func testNonSkeletonViewsAreUnaffectedByContentHooks()
    {
        let skeleton = UILabel()
        self.show(skeleton)
        let label = UILabel()
        label.text = "Normal"
        label.textColor = .purple
        XCTAssertEqual(label.text, "Normal")
        XCTAssertEqual(label.textColor, .purple)
        self.hide(skeleton)
    }

    func testAutomaticResizeWorksAfterHidingAnotherSkeleton()
    {
        let first = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let second = UIView(frame: first.frame)
        self.show(first)
        self.show(second)
        self.hide(first)
        second.bounds.size = CGSize(width: 60, height: 20)
        second.setNeedsLayout()
        second.layoutIfNeeded()
        XCTAssertEqual(second._skeletonLayer?.contentLayer.bounds.size, second.bounds.size)
        self.hide(second)
    }

    func testResizeWithoutLayoutSubviewsUpdatesImmediately()
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.show(view)
        view.bounds.size = CGSize(width: 60, height: 20)
        XCTAssertEqual(view._skeletonLayer?.contentLayer.bounds.size, view.bounds.size)
        self.hide(view)
    }

    func testBoundsOverrideConstraintsAndTransforms()
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        view.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        view.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.show(view)
        view.bounds = CGRect(x: 5, y: 7, width: 60, height: 20)
        view.layoutSkeletonIfNeeded()
        XCTAssertEqual(view._skeletonLayer?.contentLayer.frame, view.bounds)
        self.hide(view)
    }

    func testAutoLayoutResizeTracksConstraintChanges()
    {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        let width = view.widthAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([
            width,
            view.heightAnchor.constraint(equalToConstant: 40),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        self.show(view)
        container.layoutIfNeeded()
        width.constant = 60
        container.setNeedsLayout()
        container.layoutIfNeeded()
        XCTAssertEqual(view.bounds.width, 60)
        XCTAssertEqual(view._skeletonLayer?.contentLayer.bounds.width, 60)
        self.hide(view)
    }

    func testMultilineResizeRebuildsLinesAndPreservesTint()
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.numberOfLines = 0
        label.skeletonTextLineHeight = .fixed(10)
        label.skeletonLineSpacing = 10
        label.isSkeletonable = true
        label.showSkeleton(usingColor: .red, transition: .none)
        XCTAssertEqual(label._skeletonLayer?.contentLayer.skeletonSublayers.count, 5)
        label.bounds.size.height = 40
        label.layoutSkeletonIfNeeded()
        XCTAssertEqual(label._skeletonLayer?.contentLayer.skeletonSublayers.count, 2)
        label.bounds.size.height = 120
        label.layoutSkeletonIfNeeded()
        let lines = label._skeletonLayer!.contentLayer.skeletonSublayers
        XCTAssertEqual(lines.count, 6)
        XCTAssertTrue(lines.allSatisfy { $0.backgroundColor == UIColor.red.cgColor })
        self.hide(label)
    }

    func testMultilineAlignmentAndPaddingAreCorrectImmediately()
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        label.numberOfLines = 2
        label.textAlignment = .right
        label.skeletonTextLineHeight = .fixed(10)
        label.skeletonLineSpacing = 10
        label.skeletonPaddingInsets = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        label.lastLineFillPercent = 50
        self.show(label)
        let lines = label._skeletonLayer!.contentLayer.skeletonSublayers
        XCTAssertEqual(lines.last?.frame, CGRect(x: 95, y: 40, width: 85, height: 10))
        self.hide(label)
    }

    func testGradientAndAnimationSurviveLineCountChange()
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.numberOfLines = 0
        label.skeletonTextLineHeight = .fixed(10)
        label.skeletonLineSpacing = 10
        label.isSkeletonable = true
        label.showAnimatedGradientSkeleton(transition: .none)
        label.bounds.size.height = 40
        label.layoutSkeletonIfNeeded()
        let lines = label._skeletonLayer!.contentLayer.skeletonSublayers
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines.allSatisfy { ($0 as? CAGradientLayer)?.colors?.isEmpty == false })
        XCTAssertTrue(lines.allSatisfy { $0.animation(forKey: "skeletonAnimation") != nil })
        self.hide(label)
    }

    func testReshowDuringFadeOutKeepsNewSkeleton()
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.show(view)
        let oldLayer = view._skeletonLayer!.contentLayer
        view.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.05))
        self.show(view)
        let newLayer = view._skeletonLayer!.contentLayer
        XCTAssertFalse(oldLayer === newLayer)
        let completed = self.expectation(description: "Fade-out completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            XCTAssertTrue(view._skeletonLayer?.contentLayer === newLayer)
            XCTAssertTrue(view.sk.isSkeletonActive)
            completed.fulfill()
        }
        self.wait(for: [completed], timeout: 1)
        self.hide(view)
    }

    func testStackViewPlaceholderAndHeightConstraintsAreRecovered()
    {
        let label = UILabel()
        label.numberOfLines = 2
        let stack = UIStackView(arrangedSubviews: [label])
        stack.isSkeletonable = true
        label.isSkeletonable = true
        stack.showSkeleton(transition: .none)
        label.text = "Loaded"
        self.hide(stack)
        XCTAssertEqual(label.text, "Loaded")
        XCTAssertTrue(label.skeletonHeightConstraints.isEmpty)
        XCTAssertTrue(label.backupHeightConstraints.isEmpty)
    }

    func testHideReleasesLayersConfigurationAndRecoveryState()
    {
        let label = UILabel()
        label.text = "Old"
        self.show(label)
        self.hide(label)
        XCTAssertNil(label._skeletonLayer)
        XCTAssertNil(label._currentSkeletonConfig)
        XCTAssertNil(label.labelState)
        XCTAssertNil(label.viewState)
    }

    func testOriginalAttributedContentIsRestoredWithoutUpdates()
    {
        let label = UILabel()
        let text = NSAttributedString(string: "Text", attributes: [.foregroundColor: UIColor.red])
        label.attributedText = text
        self.show(label)
        self.hide(label)
        XCTAssertEqual(label.attributedText, text)
        let field = UITextField()
        field.attributedPlaceholder = text
        let expectedPlaceholder = field.attributedPlaceholder?.copy() as? NSAttributedString
        self.show(field)
        self.hide(field)
        XCTAssertEqual(field.attributedPlaceholder?.string, expectedPlaceholder?.string)
        let color = field.attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, .red)
    }

    #if SWIFT_PACKAGE
    func testPrivacyManifestIsBundled()
    {
        XCTAssertNotNil(Bundle.module.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
    }
    #endif

    func testSwitchBetweenSingleAndMultipleLines()
    {
        let previousSetting = SkeletonAppearance.default.renderSingleLineAsView
        SkeletonAppearance.default.renderSingleLineAsView = true
        defer
        {
            SkeletonAppearance.default.renderSingleLineAsView = previousSetting
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        label.numberOfLines = 1
        self.show(label)
        label.numberOfLines = 2
        label.layoutSkeletonIfNeeded()
        XCTAssertEqual(label._skeletonLayer?.contentLayer.skeletonSublayers.count, 2)
        label.numberOfLines = 1
        label.layoutSkeletonIfNeeded()
        XCTAssertEqual(label._skeletonLayer?.contentLayer.skeletonSublayers.count, 0)
        XCTAssertNotNil(label._skeletonLayer?.contentLayer.backgroundColor)
        self.hide(label)
    }
}
