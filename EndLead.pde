/*
EndLeads are only for show. They point from a lead footprint to a block. Regular leads are only block to block.
 The owner is the
 */

class EndLead extends Lead {
  Lead targetLead;

  EndLead(Block owner) {
    super(owner, 0, -1);
    options.reverse_march = true;
  }


  void SetTargetLead(Lead t) {
    targetLead = t;
  }

  public void Update() {
    if (targetLead != null) {
      trackLead(targetLead);
    }
  }

  void trackLead(Lead lead) { 
    PVector pos = lead.footprintPosition();    
    rotation = atan2((pos.y - owner.y_pos), 
    (pos.x - owner.x_pos));
    distance = dist(pos.x, pos.y, owner.x_pos, owner.y_pos);
  }
}

