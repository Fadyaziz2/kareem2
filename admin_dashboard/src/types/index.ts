export type UserRole = 
  | 'client' 
  | 'lawyer' 
  | 'super_admin' 
  | 'legal_director' 
  | 'financial_director' 
  | 'dispute_agent';

export interface User {
  _id: string;
  fullName: string;
  phone: string;
  email: string;
  role: UserRole;
  walletBalance: number;
  city: string;
  isVerified: boolean;
  createdAt: string;
}

export type LawyerDegree = 'ابتدائي' | 'استئناف' | 'نقض';
export type VerificationStatus = 'pending' | 'approved' | 'rejected';

export interface Lawyer {
  _id: string;
  userId: User;
  barNumber: string;
  degree: LawyerDegree;
  specializations: string[];
  bio?: string;
  idCardImage?: string;
  barCardImage?: string;
  verificationStatus: VerificationStatus;
  rejectionReason?: string;
  commissionRate: number;
  consultationRate: number;
  rating: number;
  totalConsultations: number;
}

export interface TemplateVariable {
  name: string;
  label: string;
  type: 'text' | 'number' | 'date' | 'select';
  options?: string[];
  required?: boolean;
  defaultValue?: string;
}

export interface Template {
  _id: string;
  title: string;
  category: string;
  description?: string;
  content: string;
  placeholders: string[];
  variables?: TemplateVariable[];
  autoGeneratePrice: number;
  lawyerReviewPrice: number;
  price: number;
  requiresReview: boolean;
  createdAt: string;
}

export interface GeneratedContract {
  _id: string;
  templateId: Template | string;
  clientId: User;
  assignedLawyerId?: User;
  contractType: 'instant' | 'lawyer_review';
  title: string;
  filledVariables: Record<string, any>;
  renderedContent: string;
  status: 'draft' | 'pending_review' | 'approved' | 'completed';
  price: number;
  paymentStatus: 'pending' | 'paid';
  lawyerNotes?: string;
  pdfUrl?: string;
  createdAt: string;
}

export type ConsultationType = 'written' | 'audio_call' | 'office_visit';
export type ConsultationStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled';

export interface ChatMessage {
  _id?: string;
  sender: User | string;
  text: string;
  attachments?: string[];
  timestamp: string;
}

export interface Consultation {
  _id: string;
  clientId: User;
  lawyerId?: User;
  type: ConsultationType;
  subject: string;
  description: string;
  attachments?: string[];
  price: number;
  status: ConsultationStatus;
  responseNotes?: string;
  messages?: ChatMessage[];
  createdAt: string;
}

export type MilestoneStatus = 
  | 'pending_deposit' 
  | 'held_in_escrow' 
  | 'submitted' 
  | 'released' 
  | 'disputed';

export interface Milestone {
  _id: string;
  title: string;
  percentage: number;
  amount: number;
  terms: string;
  status: MilestoneStatus;
  submissionNotes?: string;
  submissionFiles?: string[];
}

export type EscrowStatus = 'draft' | 'active' | 'completed' | 'disputed' | 'frozen';

export interface Escrow {
  _id: string;
  partyA: User;
  partyB: User;
  title: string;
  description?: string;
  totalAmount: number;
  contractDocument?: string;
  linkedContractId?: GeneratedContract | string;
  milestones: Milestone[];
  status: EscrowStatus;
  createdAt: string;
}

export type DisputePriority = 'low' | 'medium' | 'high' | 'urgent';
export type DisputeStatus = 'open' | 'under_investigation' | 'resolved';
export type ResolutionType = 'full_refund_partyA' | 'full_release_partyB' | 'custom_split';

export interface ArbitrationVerdict {
  resolutionType: ResolutionType;
  splitPartyA?: number;
  splitPartyB?: number;
  notes?: string;
  decidedBy?: User | string;
  decidedAt?: string;
}

export interface Dispute {
  _id: string;
  escrowId: Escrow;
  milestoneId: string;
  raisedBy: User;
  reason: string;
  details: string;
  evidenceFiles?: string[];
  priority: DisputePriority;
  status: DisputeStatus;
  arbitrationVerdict?: ArbitrationVerdict | null;
  createdAt: string;
}

export interface DashboardStats {
  totalUsers: number;
  approvedLawyers: number;
  pendingLawyers: number;
  activeEscrows: number;
  totalHeldBalance: number;
  openDisputes: number;
  totalRevenue: number;
  monthlyRevenue: Array<{
    month: string;
    contracts: number;
    consultations: number;
    escrowFees: number;
  }>;
  serviceDistribution: Array<{
    name: string;
    value: number;
    color: string;
  }>;
  urgentAlerts: {
    pendingLawyers: Lawyer[];
    activeDisputes: Dispute[];
  };
}

export interface WithdrawalRequest {
  id: string;
  lawyerName: string;
  amount: number;
  bank: string;
  iban: string;
  status: 'pending' | 'completed' | 'approved' | 'rejected';
  date: string;
}

export interface LedgerEntry {
  id: string;
  type: string;
  title: string;
  amount: number;
  party: string;
  date: string;
}

export interface FinancialStats {
  platformNetRevenue: number;
  totalEscrowVolume: number;
  pendingPayoutsAmount: number;
  completedPayoutsAmount: number;
  withdrawals: WithdrawalRequest[];
  ledger: LedgerEntry[];
}
