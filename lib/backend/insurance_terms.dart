// ShopLendr Insurance & Security Policy
// Version 1.0 - University of Antique Student Platform

class InsuranceTerms {
  static const String version = '1.0';
  static const String lastUpdated = 'October 2025';

  static const String fullTerms = '''
SHOPLENDR INSURANCE & SECURITY POLICY
Version $version - Last Updated: $lastUpdated

AGREEMENT FOR RENTAL TRANSACTIONS

By checking this box, you agree to the following terms and conditions for renting items through ShopLendr:

1. ITEM CONDITION & RESPONSIBILITY
   • You acknowledge that you have reviewed the item description and condition before requesting to rent.
   • You agree to return the item in the same condition as received, accounting for normal wear and tear.
   • You are responsible for any damage, loss, or theft of the rented item during the rental period.

2. RENTAL PERIOD
   • The rental period begins on the agreed start date and ends on the agreed end date.
   • Late returns may incur additional charges as agreed with the item owner.
   • If you need to extend the rental period, you must contact the owner before the end date.

3. PAYMENT & PROOF
   • Payment must be arranged directly between you and the item owner.
   • You must upload proof of payment (screenshot or receipt) before receiving the item.
   • ShopLendr does not process payments and is not responsible for payment disputes.

4. ITEM PICKUP & RETURN
   • You are responsible for arranging pickup and return with the item owner.
   • Meet in safe, public locations on the University of Antique campus when possible.
   • Verify the item condition during pickup and document any existing damage.

5. INSURANCE COVERAGE
   • In case of damage: You agree to compensate the owner for repair costs or replacement value.
   • In case of loss/theft: You agree to compensate the owner for the full replacement value of the item.
   • Disputes will be resolved through the ShopLendr platform and university administration if necessary.

6. PROHIBITED ITEMS
   • Do not rent items that are illegal, dangerous, or prohibited by university policy.
   • ShopLendr reserves the right to remove listings that violate these terms.

7. USER CONDUCT
   • Treat all items with care and respect.
   • Communicate promptly and professionally with item owners.
   • Report any issues or disputes through the ShopLendr platform.

8. LIMITATION OF LIABILITY
   • ShopLendr acts as a platform connecting students and is not a party to rental agreements.
   • ShopLendr is not liable for disputes, damages, losses, or injuries arising from rentals.
   • Users engage in transactions at their own risk.

9. DISPUTE RESOLUTION
   • In case of disputes, both parties agree to first attempt resolution through direct communication.
   • If unresolved, disputes may be escalated to ShopLendr support and university administration.
   • The University of Antique's student conduct policies apply to all transactions.

10. PRIVACY & DATA SECURITY
    • Your personal information is protected according to our Privacy Policy.
    • Transaction records are maintained for security and dispute resolution purposes.
    • Student ID verification is required to maintain a safe, student-only environment.

11. TERMINATION
    • ShopLendr reserves the right to suspend or terminate accounts that violate these terms.
    • Repeated violations may result in permanent ban from the platform.

12. CHANGES TO TERMS
    • ShopLendr may update these terms at any time.
    • Continued use of the platform constitutes acceptance of updated terms.

ACKNOWLEDGMENT
By checking the insurance agreement box, you confirm that you have read, understood, and agree to be bound by these terms and conditions. You acknowledge that you are a verified University of Antique student and will use the platform responsibly.

For questions or concerns, contact ShopLendr support through the app.
''';

  static const String shortSummary = '''
By agreeing, you confirm that you will:
• Return items in the same condition
• Pay for any damage, loss, or theft
• Upload proof of payment
• Follow all rental terms and university policies
''';

  static List<String> get keyPoints => [
        'Return items in the same condition as received',
        'Compensate for any damage, loss, or theft',
        'Upload proof of payment before receiving items',
        'Arrange safe pickup and return on campus',
        'Follow University of Antique student conduct policies',
        'Resolve disputes through proper channels',
      ];
}
