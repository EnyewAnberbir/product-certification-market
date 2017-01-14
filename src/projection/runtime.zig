const p_scheme_epoch_partition = @import("scheme_epoch_partition.zig");
const p_standard_revision_dense = @import("standard_revision_dense.zig");
const p_evidence_docket_cursor = @import("evidence_docket_cursor.zig");
const p_decision_quorum_plan = @import("decision_quorum_plan.zig");
const p_certificate_scope_fold = @import("certificate_scope_fold.zig");
const p_factory_surveillance_map = @import("factory_surveillance_map.zig");
const p_complaint_triage_span = @import("complaint_triage_span.zig");
const p_capa_deadline_check = @import("capa_deadline_check.zig");
const p_recall_notice_measure = @import("recall_notice_measure.zig");
const p_counterfeit_mark_batch = @import("counterfeit_mark_batch.zig");
const p_accreditation_scope_cohort = @import("accreditation_scope_cohort.zig");
const p_lab_period_extent = @import("lab_period_extent.zig");
const p_technical_file_page = @import("technical_file_page.zig");
const p_family_extension_fold = @import("family_extension_fold.zig");
const p_suspend_prune_span = @import("suspend_prune_span.zig");
const p_reinstate_gate_reaudit = @import("reinstate_gate_reaudit.zig");
const p_public_verify_bind_map = @import("public_verify_bind_map.zig");
const p_export_epoch_token_map = @import("export_epoch_token_map.zig");
const p_audit_chain_rebuild_edge = @import("audit_chain_rebuild_edge.zig");
const p_outbox_ticket_feature = @import("outbox_ticket_feature.zig");
const p_idempotency_key_segment = @import("idempotency_key_segment.zig");
const p_version_freeze_graph = @import("version_freeze_graph.zig");
const p_risk_portfolio_drain = @import("risk_portfolio_drain.zig");
const p_renewal_window_lane = @import("renewal_window_lane.zig");
const p_appeal_docket_canopy = @import("appeal_docket_canopy.zig");
const p_change_eval_hydro = @import("change_eval_hydro.zig");
const p_withdrawal_mark_facade = @import("withdrawal_mark_facade.zig");
const p_market_sample_barrier = @import("market_sample_barrier.zig");
const p_emc_directive_module = @import("emc_directive_module.zig");
const p_atex_zone_factory = @import("atex_zone_factory.zig");

const eligibility = @import("../journal/eligibility.zig");
const session_mod = @import("../lifecycle/session.zig");

pub fn resetAll() void {
    p_scheme_epoch_partition.reset();
    p_standard_revision_dense.reset();
    p_evidence_docket_cursor.reset();
    p_decision_quorum_plan.reset();
    p_certificate_scope_fold.reset();
    p_factory_surveillance_map.reset();
    p_complaint_triage_span.reset();
    p_capa_deadline_check.reset();
    p_recall_notice_measure.reset();
    p_counterfeit_mark_batch.reset();
    p_accreditation_scope_cohort.reset();
    p_lab_period_extent.reset();
    p_technical_file_page.reset();
    p_family_extension_fold.reset();
    p_suspend_prune_span.reset();
    p_reinstate_gate_reaudit.reset();
    p_public_verify_bind_map.reset();
    p_export_epoch_token_map.reset();
    p_audit_chain_rebuild_edge.reset();
    p_outbox_ticket_feature.reset();
    p_idempotency_key_segment.reset();
    p_version_freeze_graph.reset();
    p_risk_portfolio_drain.reset();
    p_renewal_window_lane.reset();
    p_appeal_docket_canopy.reset();
    p_change_eval_hydro.reset();
    p_withdrawal_mark_facade.reset();
    p_market_sample_barrier.reset();
    p_emc_directive_module.reset();
    p_atex_zone_factory.reset();
    eligibility.reset();
}

pub fn establishAll(session: *const session_mod.Session) void {
    eligibility.armFromSession(
        session.titles,
        session.seals,
        session.recovers,
        session.gens,
        session.payload_bytes,
        session.saw_seal,
        session.first_seal_index,
        session.first_recover_index,
        session.cancel_armed,
    );
    p_scheme_epoch_partition.establishFromJournal(session.payload_bytes, session.titles);
    p_standard_revision_dense.establishFromJournal(session.payload_bytes, session.titles);
    p_evidence_docket_cursor.establishFromJournal(session.payload_bytes, session.titles);
    p_decision_quorum_plan.establishFromJournal(session.payload_bytes, session.titles);
    p_certificate_scope_fold.establishFromJournal(session.payload_bytes, session.titles);
    p_factory_surveillance_map.establishFromJournal(session.payload_bytes, session.titles);
    p_complaint_triage_span.establishFromJournal(session.payload_bytes, session.titles);
    p_capa_deadline_check.establishFromJournal(session.payload_bytes, session.titles);
    p_recall_notice_measure.establishFromJournal(session.payload_bytes, session.titles);
    p_counterfeit_mark_batch.establishFromJournal(session.payload_bytes, session.titles);
    p_accreditation_scope_cohort.establishFromJournal(session.payload_bytes, session.titles);
    p_lab_period_extent.establishFromJournal(session.payload_bytes, session.titles);
    p_technical_file_page.establishFromJournal(session.payload_bytes, session.titles);
    p_family_extension_fold.establishFromJournal(session.payload_bytes, session.titles);
    p_suspend_prune_span.establishFromJournal(session.payload_bytes, session.titles);
    p_reinstate_gate_reaudit.establishFromJournal(session.payload_bytes, session.titles);
    p_public_verify_bind_map.establishFromJournal(session.payload_bytes, session.titles);
    p_export_epoch_token_map.establishFromJournal(session.payload_bytes, session.titles);
    p_audit_chain_rebuild_edge.establishFromJournal(session.payload_bytes, session.titles);
    p_outbox_ticket_feature.establishFromJournal(session.payload_bytes, session.titles);
    p_idempotency_key_segment.establishFromJournal(session.payload_bytes, session.titles);
    p_version_freeze_graph.establishFromJournal(session.payload_bytes, session.titles);
    p_risk_portfolio_drain.establishFromJournal(session.payload_bytes, session.titles);
    p_renewal_window_lane.establishFromJournal(session.payload_bytes, session.titles);
    p_appeal_docket_canopy.establishFromJournal(session.payload_bytes, session.titles);
    p_change_eval_hydro.establishFromJournal(session.payload_bytes, session.titles);
    p_withdrawal_mark_facade.establishFromJournal(session.payload_bytes, session.titles);
    p_market_sample_barrier.establishFromJournal(session.payload_bytes, session.titles);
    p_emc_directive_module.establishFromJournal(session.payload_bytes, session.titles);
    p_atex_zone_factory.establishFromJournal(session.payload_bytes, session.titles);
}

pub fn rebuildAll(round: usize, insert_burst: usize) void {
    p_scheme_epoch_partition.rebuild(round, insert_burst);
    p_standard_revision_dense.rebuild(round, insert_burst);
    p_evidence_docket_cursor.rebuild(round, insert_burst);
    p_decision_quorum_plan.rebuild(round, insert_burst);
    p_certificate_scope_fold.rebuild(round, insert_burst);
    p_factory_surveillance_map.rebuild(round, insert_burst);
    p_complaint_triage_span.rebuild(round, insert_burst);
    p_capa_deadline_check.rebuild(round, insert_burst);
    p_recall_notice_measure.rebuild(round, insert_burst);
    p_counterfeit_mark_batch.rebuild(round, insert_burst);
    p_accreditation_scope_cohort.rebuild(round, insert_burst);
    p_lab_period_extent.rebuild(round, insert_burst);
    p_technical_file_page.rebuild(round, insert_burst);
    p_family_extension_fold.rebuild(round, insert_burst);
    p_suspend_prune_span.rebuild(round, insert_burst);
    p_reinstate_gate_reaudit.rebuild(round, insert_burst);
    p_public_verify_bind_map.rebuild(round, insert_burst);
    p_export_epoch_token_map.rebuild(round, insert_burst);
    p_audit_chain_rebuild_edge.rebuild(round, insert_burst);
    p_outbox_ticket_feature.rebuild(round, insert_burst);
    p_idempotency_key_segment.rebuild(round, insert_burst);
    p_version_freeze_graph.rebuild(round, insert_burst);
    p_risk_portfolio_drain.rebuild(round, insert_burst);
    p_renewal_window_lane.rebuild(round, insert_burst);
    p_appeal_docket_canopy.rebuild(round, insert_burst);
    p_change_eval_hydro.rebuild(round, insert_burst);
    p_withdrawal_mark_facade.rebuild(round, insert_burst);
    p_market_sample_barrier.rebuild(round, insert_burst);
    p_emc_directive_module.rebuild(round, insert_burst);
    p_atex_zone_factory.rebuild(round, insert_burst);
}

pub fn cancelAll(round: usize) void {
    p_scheme_epoch_partition.noteCancel(round);
    p_standard_revision_dense.noteCancel(round);
    p_evidence_docket_cursor.noteCancel(round);
    p_decision_quorum_plan.noteCancel(round);
    p_certificate_scope_fold.noteCancel(round);
    p_factory_surveillance_map.noteCancel(round);
    p_complaint_triage_span.noteCancel(round);
    p_capa_deadline_check.noteCancel(round);
    p_recall_notice_measure.noteCancel(round);
    p_counterfeit_mark_batch.noteCancel(round);
    p_accreditation_scope_cohort.noteCancel(round);
    p_lab_period_extent.noteCancel(round);
    p_technical_file_page.noteCancel(round);
    p_family_extension_fold.noteCancel(round);
    p_suspend_prune_span.noteCancel(round);
    p_reinstate_gate_reaudit.noteCancel(round);
    p_public_verify_bind_map.noteCancel(round);
    p_export_epoch_token_map.noteCancel(round);
    p_audit_chain_rebuild_edge.noteCancel(round);
    p_outbox_ticket_feature.noteCancel(round);
    p_idempotency_key_segment.noteCancel(round);
    p_version_freeze_graph.noteCancel(round);
    p_risk_portfolio_drain.noteCancel(round);
    p_renewal_window_lane.noteCancel(round);
    p_appeal_docket_canopy.noteCancel(round);
    p_change_eval_hydro.noteCancel(round);
    p_withdrawal_mark_facade.noteCancel(round);
    p_market_sample_barrier.noteCancel(round);
    p_emc_directive_module.noteCancel(round);
    p_atex_zone_factory.noteCancel(round);
}

fn densifySparsePages() void {
    p_scheme_epoch_partition.publishMaterialize();
    p_standard_revision_dense.publishMaterialize();
    p_evidence_docket_cursor.publishMaterialize();
    p_decision_quorum_plan.publishMaterialize();
    p_certificate_scope_fold.publishMaterialize();
    p_factory_surveillance_map.publishMaterialize();
    p_complaint_triage_span.publishMaterialize();
    p_capa_deadline_check.publishMaterialize();
    p_recall_notice_measure.publishMaterialize();
    p_counterfeit_mark_batch.publishMaterialize();
    p_accreditation_scope_cohort.publishMaterialize();
    p_lab_period_extent.publishMaterialize();
    p_technical_file_page.publishMaterialize();
    p_family_extension_fold.publishMaterialize();
    p_suspend_prune_span.publishMaterialize();
    p_reinstate_gate_reaudit.publishMaterialize();
    p_public_verify_bind_map.publishMaterialize();
    p_export_epoch_token_map.publishMaterialize();
    p_audit_chain_rebuild_edge.publishMaterialize();
    p_outbox_ticket_feature.publishMaterialize();
    p_idempotency_key_segment.publishMaterialize();
    p_version_freeze_graph.publishMaterialize();
    p_risk_portfolio_drain.publishMaterialize();
    p_renewal_window_lane.publishMaterialize();
    p_appeal_docket_canopy.publishMaterialize();
    p_change_eval_hydro.publishMaterialize();
    p_withdrawal_mark_facade.publishMaterialize();
    p_market_sample_barrier.publishMaterialize();
    p_emc_directive_module.publishMaterialize();
    p_atex_zone_factory.publishMaterialize();
}

fn replayRecoveryJournal() void {
    p_scheme_epoch_partition.publishRecovery();
    p_standard_revision_dense.publishRecovery();
    p_evidence_docket_cursor.publishRecovery();
    p_decision_quorum_plan.publishRecovery();
    p_certificate_scope_fold.publishRecovery();
    p_factory_surveillance_map.publishRecovery();
    p_complaint_triage_span.publishRecovery();
    p_capa_deadline_check.publishRecovery();
    p_recall_notice_measure.publishRecovery();
    p_counterfeit_mark_batch.publishRecovery();
    p_accreditation_scope_cohort.publishRecovery();
    p_lab_period_extent.publishRecovery();
    p_technical_file_page.publishRecovery();
    p_family_extension_fold.publishRecovery();
    p_suspend_prune_span.publishRecovery();
    p_reinstate_gate_reaudit.publishRecovery();
    p_public_verify_bind_map.publishRecovery();
    p_export_epoch_token_map.publishRecovery();
    p_audit_chain_rebuild_edge.publishRecovery();
    p_outbox_ticket_feature.publishRecovery();
    p_idempotency_key_segment.publishRecovery();
    p_version_freeze_graph.publishRecovery();
    p_risk_portfolio_drain.publishRecovery();
    p_renewal_window_lane.publishRecovery();
    p_appeal_docket_canopy.publishRecovery();
    p_change_eval_hydro.publishRecovery();
    p_withdrawal_mark_facade.publishRecovery();
    p_market_sample_barrier.publishRecovery();
    p_emc_directive_module.publishRecovery();
    p_atex_zone_factory.publishRecovery();
}

fn assembleExportManifest() void {
    p_scheme_epoch_partition.publishExport();
    p_standard_revision_dense.publishExport();
    p_evidence_docket_cursor.publishExport();
    p_decision_quorum_plan.publishExport();
    p_certificate_scope_fold.publishExport();
    p_factory_surveillance_map.publishExport();
    p_complaint_triage_span.publishExport();
    p_capa_deadline_check.publishExport();
    p_recall_notice_measure.publishExport();
    p_counterfeit_mark_batch.publishExport();
    p_accreditation_scope_cohort.publishExport();
    p_lab_period_extent.publishExport();
    p_technical_file_page.publishExport();
    p_family_extension_fold.publishExport();
    p_suspend_prune_span.publishExport();
    p_reinstate_gate_reaudit.publishExport();
    p_public_verify_bind_map.publishExport();
    p_export_epoch_token_map.publishExport();
    p_audit_chain_rebuild_edge.publishExport();
    p_outbox_ticket_feature.publishExport();
    p_idempotency_key_segment.publishExport();
    p_version_freeze_graph.publishExport();
    p_risk_portfolio_drain.publishExport();
    p_renewal_window_lane.publishExport();
    p_appeal_docket_canopy.publishExport();
    p_change_eval_hydro.publishExport();
    p_withdrawal_mark_facade.publishExport();
    p_market_sample_barrier.publishExport();
    p_emc_directive_module.publishExport();
    p_atex_zone_factory.publishExport();
}

fn publishAuditDigestViews() void {
    p_scheme_epoch_partition.publishAudit();
    p_standard_revision_dense.publishAudit();
    p_evidence_docket_cursor.publishAudit();
    p_decision_quorum_plan.publishAudit();
    p_certificate_scope_fold.publishAudit();
    p_factory_surveillance_map.publishAudit();
    p_complaint_triage_span.publishAudit();
    p_capa_deadline_check.publishAudit();
    p_recall_notice_measure.publishAudit();
    p_counterfeit_mark_batch.publishAudit();
    p_accreditation_scope_cohort.publishAudit();
    p_lab_period_extent.publishAudit();
    p_technical_file_page.publishAudit();
    p_family_extension_fold.publishAudit();
    p_suspend_prune_span.publishAudit();
    p_reinstate_gate_reaudit.publishAudit();
    p_public_verify_bind_map.publishAudit();
    p_export_epoch_token_map.publishAudit();
    p_audit_chain_rebuild_edge.publishAudit();
    p_outbox_ticket_feature.publishAudit();
    p_idempotency_key_segment.publishAudit();
    p_version_freeze_graph.publishAudit();
    p_risk_portfolio_drain.publishAudit();
    p_renewal_window_lane.publishAudit();
    p_appeal_docket_canopy.publishAudit();
    p_change_eval_hydro.publishAudit();
    p_withdrawal_mark_facade.publishAudit();
    p_market_sample_barrier.publishAudit();
    p_emc_directive_module.publishAudit();
    p_atex_zone_factory.publishAudit();
}

pub fn reconcileDerivedIndexes() void {
    densifySparsePages();
}
pub fn runMaterializePipeline() void {
    densifySparsePages();
}
pub fn runRecoveryPipeline() void {
    replayRecoveryJournal();
}
pub fn runExportPipeline() void {
    assembleExportManifest();
}
pub fn runAuditPipeline() void {
    publishAuditDigestViews();
}
