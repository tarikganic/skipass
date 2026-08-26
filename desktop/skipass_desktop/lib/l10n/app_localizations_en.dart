// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SkiPass Administration';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageBosnian => 'Bosnian';

  @override
  String get languageEnglish => 'English';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonSearchHint => 'Search...';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDismiss => 'Cancel';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonUnableToLoad => 'Unable to load data';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonNoItemsAvailable => 'No items available';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonEditShort => 'Edit';

  @override
  String get commonImageTypeLabel => 'images';

  @override
  String get commonCodeLabel => 'Code';

  @override
  String get commonDescriptionLabel => 'Description';

  @override
  String get commonResortLabel => 'Resort';

  @override
  String get commonNameLabel => 'Name';

  @override
  String commonNumberRequiredMessage(String label) {
    return '$label must be a number.';
  }

  @override
  String commonPositiveRangeMessage(String label, double max) {
    return '$label must be between 0.01 and $max.';
  }

  @override
  String get commonLengthLabel => 'Length (m)';

  @override
  String get commonLengthShort => 'Length';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonComplete => 'Complete';

  @override
  String commonIntRequiredMessage(String label) {
    return '$label must be a whole number.';
  }

  @override
  String commonIntRangeMessage(String label, int min, int max) {
    return '$label must be between $min and $max.';
  }

  @override
  String get sideNavAppName => 'SkiPass';

  @override
  String get sideNavReportIncident => 'Report an issue';

  @override
  String get appFeedbackReasonMinLength =>
      'The explanation must be at least 3 characters.';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleStaff => 'Staff';

  @override
  String get loginScreenTagline => 'Ski resort administration';

  @override
  String get loginScreenDescription =>
      'Manage tickets, trails, lifts, incidents and announcements in one place.';

  @override
  String get loginScreenTitle => 'Log in';

  @override
  String get loginScreenSubtitle => 'Enter staff or administrator credentials.';

  @override
  String get loginScreenUsernameLabel => 'Username';

  @override
  String get loginScreenUsernameHint => 'e.g. desktop';

  @override
  String get loginScreenPasswordLabel => 'Password';

  @override
  String get loginScreenPasswordHint => 'Enter your password';

  @override
  String get loginScreenSubmit => 'Log in';

  @override
  String get changePasswordDialogSuccess => 'Password changed successfully.';

  @override
  String get changePasswordDialogTitle => 'Change password';

  @override
  String get changePasswordDialogCurrentLabel => 'Current password';

  @override
  String get changePasswordDialogNewLabel => 'New password';

  @override
  String get changePasswordDialogConfirmLabel => 'Confirm new password';

  @override
  String get navTickets => 'Tickets';

  @override
  String get navResorts => 'Trails and ski lifts';

  @override
  String get navBenefits => 'Benefits';

  @override
  String get navIncidents => 'Incidents';

  @override
  String get navAnnouncements => 'Announcements';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navReports => 'Reports';

  @override
  String get navUsers => 'Users';

  @override
  String get navReferenceData => 'Reference data';

  @override
  String get profileDialogUpdateSuccess => 'Profile updated.';

  @override
  String get profileDialogTitle => 'My profile';

  @override
  String get profileDialogLogout => 'Log out';

  @override
  String get profileDialogLogoutConfirmMessage =>
      'Do you want to log out of your account?';

  @override
  String get profileDialogChangePhoto => 'Change photo';

  @override
  String get profileDialogFirstNameLabel => 'First name';

  @override
  String get profileDialogLastNameLabel => 'Last name';

  @override
  String get profileDialogEmailLabel => 'E-mail';

  @override
  String get profileDialogPhoneLabel => 'Phone (optional)';

  @override
  String get profileDialogBirthDateLabel => 'Date of birth (optional)';

  @override
  String get profileDialogCityLabel => 'City (optional)';

  @override
  String get profileDialogChangePassword => 'Change password';

  @override
  String get resortsTabTrails => 'Trails';

  @override
  String get resortsTabLifts => 'Ski lifts';

  @override
  String get trailDeleteConfirmTitle => 'Delete trail';

  @override
  String trailDeleteConfirmMessage(String trailName) {
    return 'Delete trail \"$trailName\"? This action cannot be undone.';
  }

  @override
  String get trailDeleteSuccess => 'Trail deleted.';

  @override
  String get trailsSearchHint => 'Search trail by name or code';

  @override
  String get trailsAllDifficulties => 'All difficulties';

  @override
  String get trailsAddButton => 'Add trail';

  @override
  String get trailsEmptyTitle => 'No trails added';

  @override
  String get trailsEmptyMessage => 'Add the resort\'s first trail.';

  @override
  String get trailConditionButton => 'Trail condition';

  @override
  String liftOpenMaintenanceCount(int count) {
    return '$count issue(s)';
  }

  @override
  String get liftDeleteConfirmTitle => 'Delete lift';

  @override
  String liftDeleteConfirmMessage(String liftName) {
    return 'Delete lift \"$liftName\"?';
  }

  @override
  String get liftDeleteSuccess => 'Lift deleted.';

  @override
  String get liftsSearchHint => 'Search lift by name or code';

  @override
  String get commonAllStatuses => 'All statuses';

  @override
  String get liftStatusOperational => 'Operational';

  @override
  String get liftStatusNotOperational => 'Not operational';

  @override
  String get liftsAddButton => 'Add lift';

  @override
  String get liftsEmptyTitle => 'No lifts added';

  @override
  String liftRidersLabel(int current, int capacity) {
    return '$current/$capacity riders';
  }

  @override
  String get liftMaintenanceButton => 'Maintenance';

  @override
  String get skiLiftFormDialogSelectRequired =>
      'Select a resort and a lift type.';

  @override
  String get skiLiftFormDialogEditTitle => 'Edit ski lift';

  @override
  String get skiLiftFormDialogNewTitle => 'New ski lift';

  @override
  String get skiLiftFormDialogNameLabel => 'Lift name';

  @override
  String get skiLiftFormDialogCodeHint => 'LIFT-01';

  @override
  String get skiLiftFormDialogLiftTypeLabel => 'Lift type';

  @override
  String get skiLiftFormDialogCapacityLabel => 'Capacity (people/h)';

  @override
  String get skiLiftFormDialogCapacityShort => 'Capacity';

  @override
  String get skiLiftFormDialogDurationLabel => 'Ride duration (min)';

  @override
  String get skiLiftFormDialogDurationShort => 'Ride duration';

  @override
  String get skiLiftFormDialogOperationalSwitch => 'Lift is operational';

  @override
  String get trailFormDialogSelectRequired =>
      'Select a resort and a trail difficulty.';

  @override
  String get trailFormDialogEditTitle => 'Edit trail';

  @override
  String get trailFormDialogNewTitle => 'New trail';

  @override
  String get trailFormDialogNameLabel => 'Trail name';

  @override
  String get trailFormDialogCodeHint => 'STAZA-01';

  @override
  String get trailFormDialogDifficultyLabel => 'Trail difficulty';

  @override
  String get trailFormDialogVerticalDropLabel => 'Vertical drop (m)';

  @override
  String get trailFormDialogVerticalDropShort => 'Vertical drop';

  @override
  String get trailFormDialogOpenSwitch => 'Trail is open';

  @override
  String get trailFormDialogNightSkiingSwitch => 'Night skiing';

  @override
  String get trailFormDialogSnowmakingSwitch => 'Snowmaking';

  @override
  String get trailFormDialogPhotoLabel => 'Photo';

  @override
  String get trailFormDialogAddPhoto => 'Add photo';

  @override
  String trailConditionDialogTitle(String trailName) {
    return 'Condition log - $trailName';
  }

  @override
  String get trailConditionDialogSaveButton => 'Save entry';

  @override
  String get trailConditionDialogSnowDepthLabel => 'Snow depth (cm)';

  @override
  String get trailConditionDialogSnowDepthError =>
      'Snow depth must be between 0 and 800 cm.';

  @override
  String get trailConditionDialogOpenSwitch => 'Trail open';

  @override
  String get trailConditionDialogNoteLabel => 'Condition notes';

  @override
  String get trailConditionDialogNoteHint =>
      'e.g. icy patch on the lower section';

  @override
  String get trailConditionDialogHistoryTitle => 'Condition history';

  @override
  String get trailConditionDialogHistoryEmpty => 'No entries recorded yet.';

  @override
  String trailConditionDialogSnowDepthValue(int depth) {
    return '$depth cm';
  }

  @override
  String get liftMaintenanceDialogReportSuccess => 'Issue reported.';

  @override
  String get liftMaintenanceDialogCompleteTitle => 'Complete service';

  @override
  String get liftMaintenanceDialogCancelTitle => 'Cancel report';

  @override
  String get liftMaintenanceDialogReasonLabel => 'Explanation';

  @override
  String get liftMaintenanceDialogStatusUpdateSuccess =>
      'Issue status updated.';

  @override
  String liftMaintenanceDialogTitle(String liftName) {
    return 'Maintenance - $liftName';
  }

  @override
  String get liftMaintenanceDialogDescriptionLabel => 'Issue description';

  @override
  String get liftMaintenanceDialogShutdownSwitch => 'Requires lift shutdown';

  @override
  String get liftMaintenanceDialogReportButton => 'Report issue';

  @override
  String get liftMaintenanceDialogHistoryTitle => 'Maintenance history';

  @override
  String get liftMaintenanceDialogHistoryEmpty => 'No issues recorded.';

  @override
  String get liftMaintenanceDialogShutdownSuffix => 'requires shutdown';

  @override
  String get liftMaintenanceStatusReported => 'Reported';

  @override
  String get liftMaintenanceStatusInProgress => 'In progress';

  @override
  String get liftMaintenanceStatusCompleted => 'Completed';

  @override
  String get liftMaintenanceStatusCancelled => 'Cancelled';

  @override
  String get liftMaintenanceActionStart => 'Start service';

  @override
  String get ticketsTabTypes => 'Ticket types';

  @override
  String get ticketFilterStatusPending => 'Inactive';

  @override
  String get ticketFilterStatusActive => 'Active';

  @override
  String get ticketFilterStatusUsed => 'In use';

  @override
  String get ticketFilterStatusExpired => 'Expired';

  @override
  String get ticketFilterStatusCancelled => 'Cancelled';

  @override
  String get ticketsSearchHint => 'Search by holder, QR code or order number';

  @override
  String get ticketsValidateButton => 'Validate ticket';

  @override
  String get ticketsEmptyTitle => 'No tickets match the selected criteria';

  @override
  String get ticketTypeDeleteConfirmTitle => 'Delete ticket type';

  @override
  String ticketTypeDeleteConfirmMessage(String typeName) {
    return 'Delete ticket type \"$typeName\"?';
  }

  @override
  String get ticketTypeDeleteSuccess => 'Ticket type deleted.';

  @override
  String get ticketTypeAddButton => 'New ticket type';

  @override
  String get ticketTypesEmptyTitle => 'No ticket types defined';

  @override
  String get ticketTypesEmptyMessage =>
      'Add the first ski pass ticket type and set its price.';

  @override
  String get ticketTypeInactiveLabel => 'Inactive';

  @override
  String ticketTypePriceLabel(String price, int maxDays) {
    return '$price/day · up to $maxDays days';
  }

  @override
  String ticketTypeDiscountSuffix(String percent) {
    return ' · $percent% discount';
  }

  @override
  String get orderDetailCancelTitle => 'Cancel order';

  @override
  String get orderDetailCancelReasonLabel => 'Cancellation reason';

  @override
  String get orderDetailCancelConfirmButton => 'Cancel order';

  @override
  String get orderDetailStatusChangeTitle => 'Change status';

  @override
  String orderDetailStatusChangeMessage(String status) {
    return 'Move the order to status \"$status\"?';
  }

  @override
  String get orderDetailStatusUpdateSuccess => 'Order status updated.';

  @override
  String get orderDetailRefundTitle => 'Refund';

  @override
  String get orderDetailRefundReasonLabel => 'Refund reason';

  @override
  String get orderDetailRefundConfirmButton => 'Issue refund';

  @override
  String get orderDetailRefundSuccess => 'Refund recorded.';

  @override
  String get orderDetailDefaultTitle => 'Order';

  @override
  String get orderDetailDateLabel => 'Order date';

  @override
  String get orderDetailPaymentMethodLabel => 'Payment method';

  @override
  String get orderDetailTicketCountLabel => 'Ticket count';

  @override
  String get orderDetailTotalLabel => 'Total amount';

  @override
  String get orderDetailPaidLabel => 'Paid';

  @override
  String get orderDetailRefundedLabel => 'Refunded';

  @override
  String get orderDetailPaymentsTitle => 'Payments';

  @override
  String get orderDetailPaymentNotCompleted => 'Not completed';

  @override
  String get orderDetailRefundButton => 'Refund';

  @override
  String get ticketTypeDialogSelectResortRequired => 'Select a resort.';

  @override
  String get ticketTypeDialogEditTitle => 'Edit ticket type';

  @override
  String get ticketTypeDialogPricePerDayLabel => 'Price per day (KM)';

  @override
  String get ticketTypeDialogPriceShort => 'Price';

  @override
  String get ticketTypeDialogMaxDaysLabel => 'Maximum number of days';

  @override
  String get ticketTypeDialogDiscountLabel => 'Discount (%)';

  @override
  String get ticketTypeDialogMinAgeLabel => 'Minimum age';

  @override
  String get ticketTypeDialogMaxAgeLabel => 'Maximum age';

  @override
  String get ticketTypeDialogActiveSwitch => 'Active (available for purchase)';

  @override
  String get validateTicketDialogSelectLiftRequired =>
      'Select the ski lift where validation is taking place.';

  @override
  String get validateTicketDialogTitle => 'Validate ticket';

  @override
  String get validateTicketDialogSubtitle =>
      'Enter or scan the ticket\'s QR code.';

  @override
  String get validateTicketDialogLiftLabel => 'Ski lift';

  @override
  String get validateTicketDialogNoLiftsAvailable => 'No lifts operational';

  @override
  String get validateTicketDialogQrLabel => 'Ticket QR code';

  @override
  String get validateTicketDialogScanTooltip => 'Scan with camera';

  @override
  String get validateTicketDialogQrMinLengthError =>
      'QR code must be at least 8 characters.';

  @override
  String get validateTicketDialogSubmitButton => 'Validate';

  @override
  String get validateTicketDialogResultValid => 'Ticket is valid';

  @override
  String get validateTicketDialogResultInvalid => 'Ticket was not accepted';

  @override
  String validateTicketDialogHolderLabel(String name) {
    return 'Holder: $name';
  }

  @override
  String get usersScreenDeleteSelfError =>
      'You cannot delete your own user account.';

  @override
  String get usersScreenDeleteConfirmTitle => 'Delete user';

  @override
  String usersScreenDeleteConfirmMessage(String userName) {
    return 'Delete user \"$userName\"? This action cannot be undone.';
  }

  @override
  String get usersScreenDeleteSuccess => 'User deleted.';

  @override
  String get usersScreenSearchHint => 'Search by name, e-mail or username';

  @override
  String get usersScreenAllRoles => 'All roles';

  @override
  String get roleSkier => 'Skier';

  @override
  String get usersScreenAddButton => 'New user';

  @override
  String get usersScreenEmptyTitle => 'No users found';

  @override
  String usersScreenOrderCount(int count) {
    return '$count orders';
  }

  @override
  String get usersScreenNeverLoggedIn => 'Never logged in';

  @override
  String usersScreenLastLogin(String date) {
    return 'Last login: $date';
  }

  @override
  String get userFormDialogEditTitle => 'Edit user';

  @override
  String get userFormDialogRoleLabel => 'Role';

  @override
  String get userFormDialogNewPasswordLabel => 'New password (optional)';

  @override
  String get userFormDialogConfirmPasswordLabel => 'Confirm password';

  @override
  String get userFormDialogActiveSwitch => 'Active user';

  @override
  String get incidentsScreenResolveTitle => 'Resolve incident';

  @override
  String get incidentsScreenRejectTitle => 'Reject report';

  @override
  String get incidentsScreenStatusUpdateSuccess => 'Incident status updated.';

  @override
  String get incidentsScreenDeleteConfirmTitle => 'Delete report';

  @override
  String incidentsScreenDeleteConfirmMessage(int incidentId) {
    return 'Delete report #$incidentId? This action cannot be undone.';
  }

  @override
  String get incidentsScreenDeleteSuccess => 'Report deleted.';

  @override
  String get incidentsScreenSearchHint => 'Search by description or reporter';

  @override
  String get incidentsColumnReported => 'Reported';

  @override
  String get incidentsColumnInProgress => 'In progress';

  @override
  String get incidentsColumnResolved => 'Resolved';

  @override
  String get incidentsColumnRejected => 'Rejected';

  @override
  String get incidentsColumnEmpty => 'No reports';

  @override
  String get incidentsUrgentLabel => 'Urgent';

  @override
  String get incidentsScreenDeleteTooltip => 'Delete report';

  @override
  String get incidentsActionTakeOver => 'Take over';

  @override
  String get incidentsActionResolve => 'Resolve';

  @override
  String get incidentsActionReject => 'Reject';

  @override
  String get reportIncidentDialogSelectRequired =>
      'Select an incident type and location.';

  @override
  String get reportIncidentDialogSuccess => 'Incident reported.';

  @override
  String get reportIncidentDialogSubtitle =>
      'Report a fault or incident at the resort';

  @override
  String get reportIncidentDialogSubmitButton => 'Report';

  @override
  String get reportIncidentDialogTypeLabel => 'Incident type';

  @override
  String get reportIncidentDialogTrailSegment => 'Trail';

  @override
  String get reportIncidentDialogLiftSegment => 'Ski lift';

  @override
  String get reportIncidentDialogNoRecords => 'No records available';

  @override
  String get reportIncidentDialogDescriptionLabel => 'Problem description';

  @override
  String get reportIncidentDialogAddPhoto => 'Add photo (optional)';

  @override
  String get reportIncidentDialogPhotoSelected => 'Photo selected';

  @override
  String get announcementsScreenDeleteConfirmTitle => 'Delete announcement';

  @override
  String announcementsScreenDeleteConfirmMessage(String title) {
    return 'Delete announcement \"$title\"? This action cannot be undone.';
  }

  @override
  String get announcementsScreenDeleteSuccess => 'Announcement deleted.';

  @override
  String get announcementsScreenAddButton => 'Add new announcement';

  @override
  String get announcementsScreenSearchHint => 'Search by title or text';

  @override
  String get announcementsScreenAllCategories => 'All categories';

  @override
  String get announcementsScreenEmptyTitle => 'No announcements added';

  @override
  String get announcementsScreenUrgentSectionTitle => 'Urgent announcements';

  @override
  String get announcementsScreenActiveSectionTitle => 'Active announcements';

  @override
  String get announcementsScreenOthersEmpty => 'No other announcements.';

  @override
  String get announcementsScreenInactiveLabel => 'Inactive';

  @override
  String announcementsScreenPublishedLabel(String date) {
    return 'published $date';
  }

  @override
  String announcementsScreenExpiresLabel(String date) {
    return 'expires $date';
  }

  @override
  String get announcementFormDialogSelectRequired =>
      'Select a category and a resort.';

  @override
  String get announcementFormDialogExpiryError =>
      'The expiry date must be after the publish date.';

  @override
  String get announcementFormDialogPublishedLabel => 'Publish date';

  @override
  String get announcementFormDialogExpiryHelpText => 'Expiry date';

  @override
  String get announcementFormDialogEditTitle => 'Edit announcement';

  @override
  String get announcementFormDialogNewTitle => 'New announcement';

  @override
  String get announcementFormDialogTitleLabel => 'Title';

  @override
  String get announcementFormDialogContentLabel => 'Announcement text';

  @override
  String get announcementFormDialogContentShort => 'Text';

  @override
  String get announcementFormDialogCategoryLabel => 'Category';

  @override
  String get announcementFormDialogExpiryLabel => 'Expiry date (optional)';

  @override
  String get announcementFormDialogUrgentSwitch => 'Urgent announcement';

  @override
  String get announcementFormDialogActiveSwitch => 'Active (visible to users)';

  @override
  String get benefitsTabPartners => 'Partners';

  @override
  String get benefitDeleteConfirmTitle => 'Delete benefit';

  @override
  String benefitDeleteConfirmMessage(String benefitName) {
    return 'Delete benefit \"$benefitName\"? This action cannot be undone.';
  }

  @override
  String get benefitDeleteSuccess => 'Benefit deleted.';

  @override
  String get benefitsSearchHint => 'Search benefit by name';

  @override
  String get benefitsAddButton => 'Add new benefit';

  @override
  String get benefitsEmptyTitle => 'No benefits added';

  @override
  String get benefitsEmptyMessage => 'Add the first benefit or perk.';

  @override
  String get partnerDeleteConfirmTitle => 'Delete partner';

  @override
  String partnerDeleteConfirmMessage(String partnerName) {
    return 'Delete partner \"$partnerName\"? This action cannot be undone.';
  }

  @override
  String get partnerDeleteSuccess => 'Partner deleted.';

  @override
  String get partnersSearchHint => 'Search partner by name';

  @override
  String get partnersAddButton => 'Add partner';

  @override
  String get partnersEmptyTitle => 'No partners added';

  @override
  String partnerBenefitCountLabel(int count) {
    return '$count benefits';
  }

  @override
  String get benefitFormDialogSelectRequired =>
      'Select a resort and a category.';

  @override
  String get benefitFormDialogEditTitle => 'Edit benefit';

  @override
  String get benefitFormDialogNewTitle => 'New benefit';

  @override
  String get benefitFormDialogNameLabel => 'Benefit name';

  @override
  String get benefitFormDialogPartnerLabel => 'Partner (optional)';

  @override
  String get benefitFormDialogPriceLabel => 'Price (KM)';

  @override
  String get benefitFormDialogPriceError => 'Price must be a positive number.';

  @override
  String get benefitFormDialogDiscountError =>
      'Discount must be between 0 and 100.';

  @override
  String get benefitFormDialogBrandLabel => 'Brand (optional)';

  @override
  String get benefitFormDialogActiveSwitch => 'Active (available for purchase)';

  @override
  String get benefitFormDialogAddPhoto => 'Add photo';

  @override
  String get partnerFormDialogEditTitle => 'Edit partner';

  @override
  String get partnerFormDialogNewTitle => 'New partner';

  @override
  String get partnerFormDialogNameLabel => 'Partner name';

  @override
  String get partnerFormDialogContactEmailLabel => 'Contact e-mail';

  @override
  String get partnerFormDialogContactPhoneLabel => 'Contact phone';

  @override
  String get partnerFormDialogWebsiteLabel => 'Website';

  @override
  String get partnerFormDialogAddressLabel => 'Address';

  @override
  String get partnerFormDialogActiveSwitch => 'Active partner';

  @override
  String get notificationsScreenMarkAllSuccess =>
      'All notifications marked as read.';

  @override
  String get notificationsScreenMarkAllButton => 'Mark all as read';

  @override
  String get notificationsScreenEmptyTitle => 'No notifications';

  @override
  String referenceDataScreenDeleteBlockedError(int count) {
    return 'Cannot delete - related records exist ($count).';
  }

  @override
  String get referenceDataScreenDeleteConfirmTitle => 'Delete record';

  @override
  String referenceDataScreenDeleteConfirmMessage(String name) {
    return 'Delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get referenceDataScreenDeleteSuccess => 'Record deleted.';

  @override
  String get referenceDataScreenSearchHint => 'Search by name';

  @override
  String get referenceDataScreenAllCountries => 'All countries';

  @override
  String referenceDataScreenAddButton(String label) {
    return 'Add: $label';
  }

  @override
  String referenceDataScreenSortOrderLabel(int order) {
    return 'Order: $order';
  }

  @override
  String referenceDataScreenRelatedCountLabel(int count) {
    return '$count related';
  }

  @override
  String get referenceItemFormDialogSelectCountryRequired =>
      'Select a country.';

  @override
  String referenceItemFormDialogEditTitle(String label) {
    return 'Edit: $label';
  }

  @override
  String referenceItemFormDialogNewTitle(String label) {
    return 'New: $label';
  }

  @override
  String get referenceItemFormDialogIsoCodeLabel => 'ISO code';

  @override
  String get referenceItemFormDialogIsoCodeError =>
      'ISO code must have 2 or 3 letters, e.g. BA or BIH.';

  @override
  String get referenceItemFormDialogCountryLabel => 'Country';

  @override
  String get referenceItemFormDialogNoCountriesHint => 'Add a country first';

  @override
  String get referenceItemFormDialogPostalCodeLabel => 'Postal code (optional)';

  @override
  String get referenceItemFormDialogPostalCodeError =>
      'Postal code must be exactly 5 digits.';

  @override
  String get referenceItemFormDialogDescriptionLabel =>
      'Description (optional)';

  @override
  String get referenceItemFormDialogColorLabel => 'Color (HEX)';

  @override
  String get referenceItemFormDialogColorError =>
      'Color must be in HEX format, e.g. #1E88E5.';

  @override
  String get referenceItemFormDialogSortOrderLabel => 'Display order (0-100)';

  @override
  String get referenceItemFormDialogSortOrderError =>
      'Order must be between 0 and 100.';

  @override
  String get referenceItemFormDialogIconLabel => 'Icon name (optional)';

  @override
  String get referenceItemFormDialogCodeError =>
      'Code may contain uppercase letters, digits and underscores, e.g. PAYPAL.';

  @override
  String get referenceItemFormDialogUrgentSwitch => 'Urgent by default';

  @override
  String get referenceItemFormDialogOnlineSwitch => 'Online payment';

  @override
  String get referenceItemFormDialogActiveSwitch => 'Active payment method';

  @override
  String get reportsScreenDateFromHelp => 'Date from';

  @override
  String get reportsScreenDateToHelp => 'Date to';

  @override
  String reportsScreenSaveSuccess(String path) {
    return 'Report saved: $path';
  }

  @override
  String reportsScreenSaveError(String error) {
    return 'Failed to save report: $error';
  }

  @override
  String get reportsScreenSalesTitle => 'Ticket sales by day';

  @override
  String get reportsScreenFromLabel => 'From';

  @override
  String get reportsScreenToLabel => 'To';

  @override
  String get reportsScreenAllResorts => 'All resorts';

  @override
  String reportsScreenTopUsersTitle(int count) {
    return 'Top $count users';
  }

  @override
  String get reportsScreenDownloadPdf => 'Download PDF';

  @override
  String get reportsScreenPrint => 'Print';

  @override
  String get reportsScreenTotalTickets => 'Total tickets';

  @override
  String get reportsScreenTotalRevenue => 'Total revenue';

  @override
  String get reportsScreenNoDataForPeriod => 'No data for the selected period.';

  @override
  String get reportsScreenTicketCountLegend => 'Ticket count';

  @override
  String get reportsScreenRevenueLegend => 'Revenue (scaled)';

  @override
  String get reportsScreenNoPurchaseData => 'No purchase data.';
}
