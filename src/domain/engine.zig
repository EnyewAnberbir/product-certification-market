const session_mod = @import("../lifecycle/session.zig");
const standards = @import("standards.zig");
const evidence = @import("evidence.zig");
const decisions = @import("decisions.zig");
const certificates = @import("certificates.zig");
const surveillance = @import("surveillance.zig");
const complaints = @import("complaints.zig");
const recalls = @import("recalls.zig");
const public_verify = @import("public_verify.zig");
const scheme_governance = @import("scheme_governance.zig");
const lab_competence = @import("lab_competence.zig");
const factory_audit = @import("factory_audit.zig");
const technical_file = @import("technical_file.zig");
const mark_control = @import("mark_control.zig");
const sample_chain = @import("sample_chain.zig");
const accreditation_map = @import("accreditation_map.zig");
const family_matrix = @import("family_matrix.zig");
const risk_portfolio = @import("risk_portfolio.zig");
const renewal = @import("renewal.zig");
const appeal_board = @import("appeal_board.zig");
const change_control = @import("change_control.zig");
const lvd_rules = @import("lvd_rules.zig");
const emc_rules = @import("emc_rules.zig");
const radio_rules = @import("radio_rules.zig");
const machinery_rules = @import("machinery_rules.zig");
const toys_rules = @import("toys_rules.zig");
const ppe_rules = @import("ppe_rules.zig");
const medical_rules = @import("medical_rules.zig");
const ivd_rules = @import("ivd_rules.zig");
const atex_rules = @import("atex_rules.zig");
const pressure_rules = @import("pressure_rules.zig");
const construction_rules = @import("construction_rules.zig");
const battery_rules = @import("battery_rules.zig");
const rohs_rules = @import("rohs_rules.zig");
const reach_rules = @import("reach_rules.zig");
const marine_rules = @import("marine_rules.zig");
const schema_validate = @import("../schema/validate.zig");
const query_compile = @import("../query/compile.zig");
const query_eval = @import("../query/eval.zig");
const publisher = @import("../export/publisher.zig");
const notified_body = @import("notified_body.zig");
const mutual_recognition = @import("mutual_recognition.zig");
const supplier_declaration = @import("supplier_declaration.zig");
const type_examination = @import("type_examination.zig");
const production_quality = @import("production_quality.zig");
const product_verification = @import("product_verification.zig");
const unit_verification = @import("unit_verification.zig");
const full_quality = @import("full_quality.zig");
const customs_bridge = @import("customs_bridge.zig");
const market_watch = @import("market_watch.zig");
const energy_label = @import("energy_label.zig");
const ecodesign = @import("ecodesign.zig");
const packaging_waste = @import("packaging_waste.zig");
const chemical_restrict = @import("chemical_restrict.zig");
const cyber_resilience = @import("cyber_resilience.zig");
const gpsd_bridge = @import("gpsd_bridge.zig");
const ean_lookup = @import("ean_lookup.zig");
const gs1_digital = @import("gs1_digital.zig");
const udi_device = @import("udi_device.zig");
const imdrf_adverse = @import("imdrf_adverse.zig");
const vigilance_net = @import("vigilance_net.zig");
const rapex_notice = @import("rapex_notice.zig");
const icsms_case = @import("icsms_case.zig");
const nanomaterial = @import("nanomaterial.zig");
const biocidal = @import("biocidal.zig");
const cosmetic_cpnp = @import("cosmetic_cpnp.zig");
const food_contact = @import("food_contact.zig");
const textile_fibre = @import("textile_fibre.zig");
const footwear_label = @import("footwear_label.zig");
const furniture_fire = @import("furniture_fire.zig");
const toy_chem = @import("toy_chem.zig");
const noise_outdoor = @import("noise_outdoor.zig");
const gas_appliance = @import("gas_appliance.zig");
const cableway = @import("cableway.zig");
const lift_safety = @import("lift_safety.zig");
const conformity_graph = @import("conformity_graph.zig");
const clause_solver = @import("clause_solver.zig");
const timeline = @import("timeline.zig");
const evidence_matrix = @import("evidence_matrix.zig");
const batch_reconcile = @import("batch_reconcile.zig");
const market_signal = @import("market_signal.zig");
const frame_codec = @import("../format/frame_codec.zig");

pub const EngineReport = extern struct {
    standards_effective: u64 = 0,
    evidence_accepted: u64 = 0,
    decision: u64 = 0,
    certificate_active: u64 = 0,
    samples_due: u64 = 0,
    recall_armed: u64 = 0,
    verify_ok: u64 = 0,
    digest: u64 = 0,
};

pub fn run(session: *const session_mod.Session) EngineReport {
    var out: EngineReport = .{};
    const schema = schema_validate.validateSession(session);
    const stds = standards.resolveEffective(session);
    const ev = evidence.evaluate(session, &stds);
    const chain = sample_chain.build(session);
    const accred = accreditation_map.build(session, &stds);
    const family = family_matrix.build(session);
    const tech = technical_file.build(session);
    const change = change_control.evaluate(session, &tech);
    const audit = factory_audit.scoreVisit(session);
    _ = scheme_governance;
    _ = lab_competence;

    var dec = decisions.evaluate(session, &stds, &ev);
    if (!schema.ok or !sample_chain.requiredForDecision(&chain) or !accreditation_map.covers(&accred, 1)) {
        dec.outcome = .deferred;
    }
    if (family.duplicate_sku or change.manual) {
        if (dec.outcome == .approved) dec.outcome = .pending;
    }

    // Directive residual can block certificate issuance.
    const dirs = [_]u64{
        lvd_rules.assess(session).digest,
        emc_rules.assess(session).digest,
        radio_rules.assess(session).digest,
        machinery_rules.assess(session).digest,
        toys_rules.assess(session).digest,
        ppe_rules.assess(session).digest,
        medical_rules.assess(session).digest,
        ivd_rules.assess(session).digest,
        atex_rules.assess(session).digest,
        pressure_rules.assess(session).digest,
        construction_rules.assess(session).digest,
        battery_rules.assess(session).digest,
        rohs_rules.assess(session).digest,
        reach_rules.assess(session).digest,
        marine_rules.assess(session).digest,
    };
    var dir_block = false;
    if (lvd_rules.blocksCertificate(&lvd_rules.assess(session))) dir_block = true;
    if (emc_rules.blocksCertificate(&emc_rules.assess(session))) dir_block = true;
    if (medical_rules.blocksCertificate(&medical_rules.assess(session))) dir_block = true;
    if (dir_block and dec.outcome == .approved) dec.outcome = .deferred;

    var cert = certificates.issue(session, &dec);
    const mark = mark_control.issueFromCertificate(&cert, @truncate(session.seals));
    const complaint = complaints.triage(session, &cert);
    if (complaint.suspends) certificates.suspendScope(&cert, complaint.severity < 3);
    var surv = surveillance.plan(session, &cert);
    surv.samples_due +%= lvd_rules.surveillanceBoost(&lvd_rules.assess(session));
    surv.samples_due +%= emc_rules.surveillanceBoost(&emc_rules.assess(session));
    if (surv.overdue_critical) certificates.suspendScope(&cert, false);
    const recall = recalls.maybeArm(session, &cert, &complaint);
    const appeal = appeal_board.consider(session, &dec);
    if (appeal.overturned) {
        cert.active = true;
    }
    const renew = renewal.evaluate(session, &cert);
    const portfolio = risk_portfolio.score(&audit, &surv, &complaint, &recall);
    const ver = public_verify.verifyMark(&cert, mark.prefix, cert.scope_units / 2);
    const gate = query_compile.compileDecisionGate(1);
    const q = query_eval.eval(session, &gate);
    const published = publisher.publish(session, &cert);

    out.standards_effective = stds.effective;
    out.evidence_accepted = ev.accepted;
    out.decision = @intFromEnum(dec.outcome);
    out.certificate_active = if (cert.active) 1 else 0;
    out.samples_due = surv.samples_due;
    out.recall_armed = if (recall.armed) 1 else 0;
    out.verify_ok = if (ver.ok and q.ok and q.value != 0) 1 else 0;
    var acc: u64 = 0;
    acc = notified_body.foldInto(acc, &notified_body.evaluate(session));
    acc = mutual_recognition.foldInto(acc, &mutual_recognition.evaluate(session));
    acc = supplier_declaration.foldInto(acc, &supplier_declaration.evaluate(session));
    acc = type_examination.foldInto(acc, &type_examination.evaluate(session));
    acc = production_quality.foldInto(acc, &production_quality.evaluate(session));
    acc = product_verification.foldInto(acc, &product_verification.evaluate(session));
    acc = unit_verification.foldInto(acc, &unit_verification.evaluate(session));
    acc = full_quality.foldInto(acc, &full_quality.evaluate(session));
    acc = customs_bridge.foldInto(acc, &customs_bridge.evaluate(session));
    acc = market_watch.foldInto(acc, &market_watch.evaluate(session));
    acc = energy_label.foldInto(acc, &energy_label.evaluate(session));
    acc = ecodesign.foldInto(acc, &ecodesign.evaluate(session));
    acc = packaging_waste.foldInto(acc, &packaging_waste.evaluate(session));
    acc = chemical_restrict.foldInto(acc, &chemical_restrict.evaluate(session));
    acc = cyber_resilience.foldInto(acc, &cyber_resilience.evaluate(session));
    acc = gpsd_bridge.foldInto(acc, &gpsd_bridge.evaluate(session));
    acc = ean_lookup.foldInto(acc, &ean_lookup.evaluate(session));
    acc = gs1_digital.foldInto(acc, &gs1_digital.evaluate(session));
    acc = udi_device.foldInto(acc, &udi_device.evaluate(session));
    acc = imdrf_adverse.foldInto(acc, &imdrf_adverse.evaluate(session));
    acc = vigilance_net.foldInto(acc, &vigilance_net.evaluate(session));
    acc = rapex_notice.foldInto(acc, &rapex_notice.evaluate(session));
    acc = icsms_case.foldInto(acc, &icsms_case.evaluate(session));
    acc = nanomaterial.foldInto(acc, &nanomaterial.evaluate(session));
    acc = biocidal.foldInto(acc, &biocidal.evaluate(session));
    acc = cosmetic_cpnp.foldInto(acc, &cosmetic_cpnp.evaluate(session));
    acc = food_contact.foldInto(acc, &food_contact.evaluate(session));
    acc = textile_fibre.foldInto(acc, &textile_fibre.evaluate(session));
    acc = footwear_label.foldInto(acc, &footwear_label.evaluate(session));
    acc = furniture_fire.foldInto(acc, &furniture_fire.evaluate(session));
    acc = toy_chem.foldInto(acc, &toy_chem.evaluate(session));
    acc = noise_outdoor.foldInto(acc, &noise_outdoor.evaluate(session));
    acc = gas_appliance.foldInto(acc, &gas_appliance.evaluate(session));
    acc = cableway.foldInto(acc, &cableway.evaluate(session));
    acc = lift_safety.foldInto(acc, &lift_safety.evaluate(session));
    acc = conformity_graph.fold(session, acc);
    acc = clause_solver.fold(session, acc);
    acc = timeline.fold(session, acc);
    acc = evidence_matrix.fold(session, acc);
    acc = batch_reconcile.fold(session, acc);
    acc = market_signal.fold(session, acc);
    {
        var keybuf: [16]u32 = undefined;
        var k: usize = 0;
        while (k < keybuf.len) : (k += 1) keybuf[k] = @truncate(session.payload_bytes +% k * 13);
        var framebuf: [128]u8 = undefined;
        const packed_n = frame_codec.packKeysFrame(keybuf[0..], framebuf[0..]);
        if (packed_n > 24) acc = frame_codec.foldBody(framebuf[24..packed_n], acc);
    }
    out.digest = acc ^ stds.digest ^ ev.digest ^ dec.digest ^ cert.digest ^ surv.digest ^ complaint.digest
        ^ recall.digest ^ ver.digest ^ schema.digest ^ chain.digest ^ accred.digest ^ family.digest
        ^ tech.hash ^ change.digest ^ audit.score ^ mark.digest ^ appeal.digest ^ renew.digest
        ^ portfolio.score ^ published.digest ^ dirs[0] ^ dirs[7] ^ dirs[14];
    return out;
}
