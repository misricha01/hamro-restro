/// Whether a staff member's ledger balance is money the business owes them
/// (To Pay / Advanced) or money they owe the business (To Collect / Debit).
///
/// This backend has no ledger/balance concept for staff users — Adjust
/// Balance stays a local-only, unpersisted UI concern built on this enum
/// rather than on [StaffMember].
enum StaffBalanceType { toCollect, toPay }
